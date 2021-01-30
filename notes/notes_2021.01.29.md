# Moving git repos

*2021.01.29*

Our git host at work is being migrated from github Enterprise to gitea. Porting over my private repositories, I used the following commands to preserve the history/branches/tags/etc.

View the remotes.

```
    git remote -v
```

Remove the old origin.

```
    git remote remove origin
```

Add the new repository location.

```
    git remote add origin url
```

Push all content to the new source.

```
    git push origin --all
    git push --tags
```

