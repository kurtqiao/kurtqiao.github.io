@echo off
REM  License: GPLv3
REM  Author: KurtQiao, 2015-1-14
REM  Descript: A simple batch to create new jekyll POST markdown file.
REM  Usage: newpost.bat "This is a test post title"
REM  the batch will create a markdown file with the name of given post title in current folder,
REM  content with jekyll post format.

:start
if "%~1" == "" (
  echo need follow a file name!
  goto end
)

REM get system date and change to format 2015-01-01
set mdate=%date:~0,4%-%date:~5,2%-%date:~8,2%
REM get system time and remove mini second
set mtime=%time:~0,-3%

set orifn=%~1
REM replace space with '-' to make a post file name
set "postfn=%mdate%-%orifn: =-%"

REM POST format content to markdown file
(
echo --- 
echo layout: post
echo title:  "%orifn%"
echo date:   %mdate% %mtime%
echo categories: UEFI
echo --- 
)>> %postfn%.md 

:end

