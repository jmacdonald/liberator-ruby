# Liberator [![Build Status](https://travis-ci.org/jmacdonald/liberator.png)](https://travis-ci.org/jmacdonald/liberator)

Running out of space on your Linux/BSD server?

Liberator is a command-line app for navigating directories and deleting large files and folders. It uses a server-friendly curses interface that makes the task _almost_ enjoyable.

## Installation

Liberator requires Ruby >= 1.9, and is available as a gem:

```
$ gem install liberator
```

## Usage

From any directory, run the liberator executable to fire it up:

```
$ liberator
```

You'll be presented with a directory listing, with entries ordered by size.

### Navigation

Navigation cues are taken from Vi. Here's a quick rundown:

`j` Select the next entry

`k` Select the previous entry

`h` Move to the parent directory

`<enter>` Enter the selected directory

`x` Delete the current selection

### Permissions

There are two situations in which insufficient permissions result in limited functionality:

#### Unreadable Directories

If you don't have permission to read a directory, you'll notice a hyphen `-` displayed where its size should be.

#### Unwritable Directories

If you don't have permission to write a directory, you won't be able to delete it or any of its entries.

## License
Copyright &copy; 2013 Jordan MacDonald.

Distributed under the GPLv3 License. See LICENSE for further details.
