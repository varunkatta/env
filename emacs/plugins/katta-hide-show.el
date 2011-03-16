;; C-c @ C-M-s show all
;; C-c @ C-M-h hide all
;; C-c @ C-s show block
;; C-c @ C-h hide block
;; C-c @ C-c toggle hide/show


;; (global-set-key (kbd "M-=") 'hs-hide-all)
;; (global-set-key (kbd "M--") 'hs-show-all)
(global-set-key [M-=] 'hs-hide-all)
(global-set-key [M--]'hs-show-all)
(global-set-key [f1] 'hs-hide-level)
(global-set-key [f2] 'hs-hide-block)
(global-set-key [f3] 'hs-show-block)

(add-hook 'c-mode-common-hook   'hs-minor-mode)
(add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
(add-hook 'java-mode-hook       'hs-minor-mode)
(add-hook 'lisp-mode-hook       'hs-minor-mode)
(add-hook 'perl-mode-hook       'hs-minor-mode)
(add-hook 'sh-mode-hook         'hs-minor-mode)
(add-hook 'python-mode-hook     'hs-minor-mode)
