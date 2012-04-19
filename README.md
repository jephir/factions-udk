# Empires UDK

This repository contains submodules for Empires UDK development.

## Installation

1. [Download and install UDK](http://udk.com/download).
2. Clone this repository to your UDK installation directory (e.g. `C:\UDK\UDK-2012-03`).
3. Initialize and update all the submodules.
4. Add `+EditPackages=EmpGame` to the end of the `[UnrealEd.EditorEngine]` section in `UDKGame/Config/DefaultEngine.ini`.
5. Set `Map=TestMap.udk` and `LocalMap=TestMap.udk` under `[URL]` in the same file.
6. Set `DefaultGame=EmpGame.EmpGame`, `DefaultServerGame=EmpGame.EmpGame`, and `DefaultGameType="EmpGame.EmpGame";` under `[Engine.GameInfo]` in `UDKGame/Config/DefaultGame.ini`.

## Pulling Changes

1. **IMPORTANT:** Use **rebase** when updating your submodules! Do **not** use merge!

## Committing Changes

1. Use this [commit message template](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).
2. Commit in each submodule that is changed. For example, if you modify the code and content submodules, commit to **and** push both of those submodules. Make each commit message specific to what is being changed in that submodule.

## Miscellaneous

* Send a message to [jephir](https://bitbucket.org/jephir) if you need a new submodule for the folder you're working on.