Jekyll Personal Website History
===
>author: kurtqiao  
>Jekyll version: 2.15.2  
>on: windows8.1  

Start
---
>time: 12.23.2014

1. set up enviroment  
 http://rubyinstaller.org/downloads/  
 download and install RubyInstaller.exe  
 download and install Devkit  
2. cd devkit into folder  
  ruby dk.rb init  
  ruby dk.rb install  
3. install jekyll  
  change gem source to ruby.taobo.org  
  gem install jekyll  
  jekyll -v  
  check version success and install ok.  
4. create your website project  
  into your project folder  
  jekyll new website_name  
5. local review  
  jekyll serve  
  open localhost:4000 and check

*refer:*<http://www.cnblogs.com/yevon/p/3308158.html>  

Google code pretty
---
1. download  
  <https://code.google.com/p/google-code-prettify/downloads>  
2. extract to project folder
3. download css styles, you can change display style in here
4. add css style in head.html, add prettify.js and jqueryxxx.js in default.html
5. use '<pre></pre>' to hightlihgt code in markdown

