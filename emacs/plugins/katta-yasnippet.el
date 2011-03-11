(add-to-list 'load-path "~/env/emacs/yasnippet")
(require 'yasnippet) 
(yas/initialize)
(setq yasnippet-dir "~/env/emacs/yasnippet/snippets")
(yas/load-directory yasnippet-dir)

;; hook for automatic reloading of changed snippets
(defun update-yasnippets-on-save ()
  (when (string-match "/yasnippet/snippets" buffer-file-name)
    (yas/load-directory yasnippet-dir)))
(add-hook 'after-save-hook 'update-yasnippets-on-save)

