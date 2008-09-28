(defun transform-signatures ()
  (interactive)
  (while (re-search-forward "^\\([a-zA-Z0-9_]*\\): \"\\(([^)]*)\\)\\(\\[\\([a-z]*\\)\\]\\)?\\([^\"]*\\)\"$" nil t)
    (replace-match "(\"\\1\" \"\\4 \\1\\2 \\5\"))" nil nil)))

(defun transform-events ()
  (interactive)
  (goto-char (point-min))
  (delete-matching-lines "^ll")
  (while (re-search-forward "^\\([a-zA-Z0-9_]*\\): \"\\(([^)]*)\\)\\(\\[\\([a-z]*\\)\\]\\)?\\([^\"]*\\)\"$" nil t)
    (replace-match "(define-skeleton \\1-skeleton
    \"\\1 handler skeleton\"
  nil
  \\\\n >
  \"\\1\\2\"
  \\\\n >
  \"{\"
  \\\\n >
  _
  \\\\n >
  \"}\")
(define-abbrev c-mode-abbrev-table \"skel\\1\" \"\" '\\1-skeleton)" nil nil)))
