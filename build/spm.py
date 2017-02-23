#!/usr/bin/env python

import os
import yaml
import shutil
import tempfile
import subprocess


def git_clone(source, branch=None, destination=None):
    # TODO - replace with a better function if this goes more than a PoC
    args = ['git', 'clone', source]
    if branch:
        args += ['--branch', branch, '--single-branch']
    if destination:
        args.append(destination)

    args.append('2>&1')
    out = subprocess.check_output(' '.join(args), shell=True)
    if len(out.split('\n')) == 2:
        return True
    return False


def git_get_latest_commit(directory=None, ref='HEAD'):
    # TODO - replace with a better function if this goes more than a PoC
    if not directory:
        directory = os.getcwd()
    old_dir  = os.getcwd()
    os.chdir(directory)
    args = ['git', 'rev-parse', ref]
    out = subprocess.check_output(' '.join(args), shell=True)
    out = out.rstrip('\n')
    os.chdir(old_dir)
    if len(out) == 40:
        return out
    return None


def git_reset(directory, ref, hard=True):
    # TODO - replace with a better function if this goes more than a PoC
    old_dir  = os.getcwd()
    os.chdir(directory)
    args = ['git', 'reset', ref]
    if hard:
        args.append('--hard')
    out = subprocess.check_output(' '.join(args), shell=True)
    os.chdir(old_dir)
    if len(out.split('\n')) == 2:
        return True
    return False


class Formula(object):
    def __init__(self, name, source, branch='master', sha='HEAD', directory=None):
        self.name = name
        self.source = source
        self.branch = branch
        self.sha = sha
        self.directory = directory
        if not directory:
            self.directory = os.path.join(os.getcwd(), 'formulas')
        self.path = os.path.join(self.directory, self.name)

    def is_current(self):
        # If the directory or SHA file are missing, consider it not current.
        if not os.path.isdir(self.path):
            return False
        if not os.path.isfile(os.path.join(self.path, 'SHA')):
            return False

        # If hashes match, we're good.
        with open(os.path.join(self.path, 'SHA'), 'rb') as fh:
            sha = fh.read().rstrip('\n')
            if self.sha == sha:
                return True
        return False

    def update(self):
        tmpdir = tempfile.mkdtemp()

        try:
            clone_success = git_clone(self.source, self.branch, tmpdir)
            if not clone_success:
                print('Failed to clone.')
                return False

            reset_success = git_reset(tmpdir, self.sha, hard=True)
            if not reset_success:
                print('Failed to reset.')
                return False

            sha = git_get_latest_commit(directory=tmpdir, ref='HEAD')
            if not sha:
                return False

            with open(os.path.join(tmpdir, self.name, 'SHA'), 'w+') as fh:
                fh.write(sha)

            if os.path.exists(self.path):
                shutil.rmtree(self.path)
            shutil.copytree(os.path.join(tmpdir, self.name), self.path)

        finally:
            if os.path.exists(tmpdir):
                shutil.rmtree(tmpdir)
        return True

    def __repr__(self):
        return str(self.__dict__)


class Saltfile(object):
    def __init__(self, path='./Saltfile'):
        self.path = path
        self.formulas = []
        self.load()

    def load(self):
        with open(self.path, 'rb') as fh:
            cfg = yaml.load(fh)
            for f in cfg.get('formulas', []):
                formula = Formula(f['name'], f['source'], f.get('branch', 'master'), f.get('sha', 'HEAD'), f.get('directory'))
                self.formulas.append(formula)

    def __repr__(self):
        return str(self.__dict__)


def main():
    config = Saltfile()
    for formula in config.formulas:
        if formula.is_current():
            print ('Formula {0} is already current.'.format(formula.name))
            continue
        print('Updating formula {0}.'.format(formula.name))
        result = formula.update()
        if not result:
            print('Failed to update formula {0}'.format(formula.name))
            sys.exit(1)


if __name__ == '__main__':
    main()
