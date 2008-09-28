(defun extract-constants ()
  (mapcar (lambda (quoted-string)
            (substring (substring quoted-string 1) 0 (- (length quoted-string) 2)))
          (split-string (shell-command-to-string "grep -o '\"[A-Z_]\\+\"' indra.l"))))

(defun extract-functions ()
  (split-string (shell-command-to-string "grep -o 'new LLScriptLibraryFunction([^;]*;' lscript_library.cpp") "[\n]+"))

