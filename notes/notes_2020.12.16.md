# Git Undo Last Commit

*2020.12.16*

```
git reset head~1 --soft
```

This will move the pointer of head back one commit and keep the changes that were made (they will be staged). 

**--soft** is what retains the changes.

Suppose you then commit and try to push to a remote. If the remote already has a commit that was made previously, you may need to use the force flag **(-f | --force)** to override that commit if it is desired to do so. 

```
git push origin trunk -f
```

