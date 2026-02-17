;;; init.el -*- lexical-binding: t; -*-

;; ----------------------------
;; Package System Bootstrap
;; ----------------------------
(require 'package)
(package-initialize)

;; Refresh package contents if needed
(unless package-archive-contents
  (package-refresh-contents))

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; ----------------------------
;; Load Configuration Modules
;; ----------------------------
(add-to-list 'load-path (expand-file-name "config" user-emacs-directory))

;; Set custom file location
(setq custom-file (locate-user-emacs-file "config/custom.el"))
(load custom-file t)

;; Load modular configuration
(require 'editor)       ; Basic editor settings
(require 'ui)           ; UI and appearance
(require 'completion)   ; Completion framework (Vertico)
(require 'lsp)          ; Eglot (LSP client)
(require 'programming)  ; Programming modes and tools
(require 'tools)        ; Utility packages
(require 'functions)    ; Custom functions

;; ----------------------------
;; Post-Startup Optimization
;; ----------------------------
;; Restore GC threshold after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 128 1024 1024)  ; 128MB
                  gc-cons-percentage 0.2)))

;;; init.el ends here
