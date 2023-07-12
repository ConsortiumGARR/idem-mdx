Hooks
=====

Teoria sui git hooks: <https://git-scm.com/book/it/v2/Customizing-Git-Git-Hooks>

L'hooks pre-commit qui presente, controlla che tutti i file che hanno come nome vault.* siano stati criptati usando ansible vault. Se non lo sono, il commit viene negato.

Per abilitarlo:

```console
chmod +x hooks/pre-commit
cp hooks/pre-commit .git/hooks/
```
