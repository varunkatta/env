;;; init-auto-complete.el --- Configuration for auto-complete mode

;; Filename: init-auto-complete.el
;; Description: Configuration for auto-complete mode
;; Author: Andy Stewart lazycat.manatee@gmail.com
;; Maintainer: Andy Stewart lazycat.manatee@gmail.com
;; Copyright (C) 2008, 2009, Andy Stewart, all rights reserved.
;; Created: 2008-12-02 11:08:12
;; Version: 0.1
;; Last-Updated: 2008-12-02 11:08:15
;;           By: Andy Stewart
;; URL:
;; Keywords: auto-complete
;; Compatibility: GNU Emacs 23.0.60.1
;;
;; Features that might be required by this library:
;;
;; `auto-complete' `auto-complete-extension'
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.


;;; Commentary:
;;
;; Configuration for auto-complete mode
;;

;;; Installation:
;;
;; Put init-auto-complete.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-auto-complete)
;;
;; No need more.

;;; Change log:
;;
;; 2008/12/02
;;      First released.
;;

;;; Acknowledgements:
;;
;;
;;

;;; TODO
;;
;;
;;


(require 'auto-complete)

;;; Code:

(add-to-list 'ac-dictionary-directories "~/env/emacs/auto-complete/dict")
(require 'auto-complete-config)
(ac-config-default)
(ac-set-trigger-key "TAB")
(setq ac-auto-start nil)
;; Generic setup.
(global-auto-complete-mode t)           ;enable global-mode
(setq ac-auto-start t)                  ;automatically start
(setq ac-dwim t)                        ;Do what i mean
(setq ac-override-local-map nil)        ;don't override local map

;; The mode that automatically startup.
(setq ac-modes
      '(emacs-lisp-mode lisp-interaction-mode lisp-mode scheme-mode
                        c-mode cc-mode c++-mode java-mode
                        perl-mode cperl-mode python-mode ruby-mode
                        ecmascript-mode javascript-mode php-mode css-mode
                        makefile-mode sh-mode fortran-mode f90-mode ada-mode
                        xml-mode sgml-mode
                        haskell-mode literate-haskell-mode
                        emms-tag-editor-mode
                        asm-mode
                        org-mode))
;; (add-to-list 'ac-trigger-commands 'org-self-insert-command) ; if you want enable auto-complete at org-mode, uncomment this line
;; The sources for common all mode.
(custom-set-variables
 '(ac-sources
   '(
     ac-source-ropemacs
     ac-source-yasnippet ;this source need file `auto-complete-yasnippet.el'
     ;; ac-source-semantic    ;this source need file `auto-complete-semantic.el'
     ac-source-imenu
     ac-source-abbrev
     ac-source-words-in-buffer
     ac-source-files-in-current-dir
     ac-source-filename
     
     ;; ac-pythons-source
     )))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Lisp mode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(dolist (hook (list
               'emacs-lisp-mode-hook
               'lisp-interaction-mode
               ))
  (add-hook hook '(lambda ()
                    (add-to-list 'ac-sources 'ac-source-symbols))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; C-common-mode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enables omnicompletion with `c-mode-common'.
(add-hook 'c-mode-common-hook
          '(lambda ()
             (add-to-list 'ac-omni-completion-sources
                          (cons "\\." '(ac-source-semantic)))
             (add-to-list 'ac-omni-completion-sources
                          (cons "->" '(ac-source-semantic)))
             (add-to-list 'ac-sources 'ac-source-gtags)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; C++-mode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Keywords.
(add-hook 'c++-mode-hook '(lambda ()
                            (add-to-list 'ac-sources 'ac-c++-sources)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Haskell mode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Keywords.
(add-hook 'haskell-mode-hook '(lambda ()
                                (add-to-list 'ac-sources 'ac-source-haskell)))

;; all the lines below are to add ropemacs extensions to python.
;; (add-hook 'python-mode-hook '(lambda ()
;;                                 (add-to-list 'ac-sources 'ac-source-ropemacs)))

;; (define-key ac-completing-map "\e" 'ac-stop)
;; (defun ac-rope-interference-breaker ()
;;   (ac-stop)
;;   (dabbrev-expand)
;; )
;; (global-set-key [M-/] 'ac-rope-interference-breaker)

(provide 'init-auto-complete)






;;; init-auto-complete.el ends here

;; (require 'auto-complete)
;; (global-auto-complete-mode t)
;; (add-to-list 'ac-dictionary-directories "~/env/emacs/auto-complete/dict")
;; (require 'auto-complete-config)
;; (ac-config-default)

;; ;; 
;; (setq ac-auto-start 3)
;; ;; (setq ac-dwim t)

;; (define-key ac-completing-map "\ESC" 'ac-stop)
;; (when (require 'auto-complete nil t)
;;   (require 'auto-complete-yasnippet)
;;   (require 'auto-complete-python)
;;   (require 'auto-complete-css) 
;;   (require 'auto-complete-cpp)  
;;   (require 'auto-complete-emacs-lisp)  
;;   (require 'auto-complete-semantic)  
;;   (require 'auto-complete-gtags)

;;   (global-auto-complete-mode t)
;;   (setq ac-auto-start 3)
;;   (setq ac-dwim t)
;;   (set-default 'ac-sources '(ac-source-yasnippet ac-source-abbrev ac-source-words-in-buffer ac-source-files-in-current-dir ac-source-symbols))
;; )
