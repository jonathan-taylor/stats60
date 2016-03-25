#!/usr/bin/env python
""" Script to check and install dependencies for stats 60

Run with:

    python check_install.py
"""
from __future__ import print_function

import sys
from os.path import join as pjoin, isdir
from subprocess import Popen, PIPE
from distutils.version import LooseVersion
import shutil
# Requires Python 2.7 or installation of argparse package
from argparse import ArgumentParser

MIN_IPYTHON='1.0.0'
R_LIBS=['alr3']


def back_tick(cmd, ret_err=False, as_str=True, raise_err=None):
    """ Run command `cmd`, return stdout, or stdout, stderr if `ret_err`

    Roughly equivalent to ``check_output`` in Python 2.7

    Parameters
    ----------
    cmd : sequence
        command to execute
    ret_err : bool, optional
        If True, return stderr in addition to stdout.  If False, just return
        stdout
    as_str : bool, optional
        Whether to decode outputs to unicode string on exit.
    raise_err : None or bool, optional
        If True, raise RuntimeError for non-zero return code. If None, set to
        True when `ret_err` is False, False if `ret_err` is True

    Returns
    -------
    out : str or tuple
        If `ret_err` is False, return stripped string containing stdout from
        `cmd`.  If `ret_err` is True, return tuple of (stdout, stderr) where
        ``stdout`` is the stripped stdout, and ``stderr`` is the stripped
        stderr.

    Raises
    ------
    Raises RuntimeError if command returns non-zero exit code and `raise_err` is
    True
    """
    if raise_err is None:
        raise_err = False if ret_err else True
    cmd_is_seq = isinstance(cmd, (list, tuple))
    proc = Popen(cmd, stdout=PIPE, stderr=PIPE, shell=not cmd_is_seq)
    out, err = proc.communicate()
    retcode = proc.returncode
    cmd_str = ' '.join(cmd) if cmd_is_seq else cmd
    if retcode is None:
        proc.terminate()
        raise RuntimeError(cmd_str + ' process did not terminate')
    if raise_err and retcode != 0:
        raise RuntimeError(cmd_str + ' process returned code %d' % retcode)
    out = out.strip()
    if as_str:
        out = out.decode('latin-1')
    if not ret_err:
        return out
    err = err.strip()
    if as_str:
        err = err.decode('latin-1')
    return out, err


def check_R():
    try:
        back_tick(['R', '--version'])
    except RuntimeError:
        print("You may need to install R - see http://www.R-project.org")
        return False
    print('R: OK')
    return True


def check_rpy2():
    try:
        import rpy2
    except ImportError:
        print('Need rpy2 python package installed - see: '
              'http://rpy.sourceforge.net for instructions')
        return False
    print('rpy2: OK')
    return True


def check_rlib(name):
    out, err = back_tick(
        ['R', '--slave', '-e', 'library({0})'.format(name)],
        ret_err=True)
    if 'Error in library' in err:
        print("Missing R library '{0}'; "
              "try `install.packages('{0}')` in R".format(name))
        return False
    print("R library '{0}': OK".format(name))
    return True


def check_ipython():
    try:
        import IPython
    except ImportError:
        print('Need ipython installed - see '
              'http://ipython.org for instructions')
        return False
    if LooseVersion(IPython.__version__) < LooseVersion(MIN_IPYTHON):
        print('Version of IPython is too old; please upgrade - see '
              'http://ipython.org for instructions')
        return False
    print('IPython: OK')
    return True

def main():
    parser = ArgumentParser(
        description='Check / install script for stats notebooks')
    args = parser.parse_args()
    if check_R():
        for name in R_LIBS:
            check_rlib(name)
    check_rpy2()
    check_ipython()

if __name__ == '__main__':
    main()
