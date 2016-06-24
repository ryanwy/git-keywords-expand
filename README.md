# git-keywords-expand

## Description:

Not like what we are setting keywords automatic replacement in SVN, Git doesn't own this magic. This small project is to implement  keywords substitution in GIT.

Thanks to Git has the attributes filter and hooks, we can use them to realize it. 

** Note that: we can only keep the local files in working area getting the latest commit information. The files you commit to reposity will be always the second newest commit information.**   
** You can keep consistency between your local working aera and the reposity. But this is based on what you accept the truth that you ignore the latest commit version. **

Keywords:　$Id$ $Author$ $Date$ $Revision$ $Header$



## usage:

### using hooks:

1. just put the post-commit file under .git/hooks/

(every time after your commit, the post-commit script is triggered, and it'll commit the file again and update the version information to your local files.)

######################

### using filters and hooks:

#### using clean command:

(every time you commit your file, the post-commit will be triggered to update your local files keywords)

1. put the whole folder .git_filter/ from filters/.git_filter/ under your project root path

2. add to .git/config as what in file filters/config:  
[filter "keywords_filter"]
    clean = .git_filter/keywords_filter.pl -t clean -f %f  
(You can choose one either clean or smudge)
3. add to .gitattributes as what in file filters/.gitatrributes  
*.txt filter=test_filter  
(you can write your own file suffix you want to filter)

4. put the hooks/post-commit-clean-filter file under .git/hooks/  
(if use it, you must change the name to post-commit)


#### using smudge command:
(every time when you finish your commit, hook script will be triggered, and update the local files keywords)

1. put the whole folder .git_filter/ from filters/.git_filter/ under your project root path
2. add to .git/config as what in file filters/config:  
[filter "keywords_filter"]
    smudge = .git_filter/keywords_filter.pl -t smudge -f %f  
(You can choose one either clean or smudge)  
3. add to .gitattributes as what in file filters/.gitatrributes
*.txt filter=test_filter  
(you can write your own file suffix you want to filter)  
4. put the hooks/post-commit file under .git/hooks/

------------------------------

在SVN里我们可以设置关键字替换，来实现代码中$Revision$,$Author$等的自动替换。但是Git没有这个特性，Git自带的$Id$关键字，替换的blob对象，而不是commit对象，而且不像SVN的增量版本，我们看不出来这个版本是新版本还是旧版本。

Git有filters和hooks特性可以帮助我们实现关键字替换，但是这种替换只能保证本地文件的版本最新，版本库中的版本永远都是上一个版本，这里的上一个版本指的是关键字替换版本，而不是实际上你要提交的更新。

使用上面提到的方法来实现git的关键字替换。
