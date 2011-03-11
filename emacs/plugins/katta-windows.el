(require 'windows)
(win:startup-with-window)
(define-key ctl-x-map "C" 'see-you-again)

(autoload 'save-current-configuration "revive" "Save status" t)


(autoload 'resume "revive" "Resume Emacs" t)
(autoload 'wipe "revive" "Wipe Emacs" t)

;;; And define favorite keys to those functions. Here is a sample.
(define-key ctl-x-map "S" 'save-current-configuration)
(define-key ctl-x-map "F" 'resume)
(define-key ctl-x-map "K" 'wipe) 
