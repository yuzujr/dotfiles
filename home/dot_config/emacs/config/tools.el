;;; tools.el -*- lexical-binding: t; -*-

(provide 'tools)

;; ----------------------------
;; Git - Magit
;; ----------------------------
(use-package magit
  :bind (("C-c g" . magit-status)
         ("C-c c d" . magit-dispatch)
         ("C-c c f" . magit-file-dispatch)))

;; ----------------------------
;; Terminal - VTerm
;; ----------------------------
(use-package vterm
  :bind (("C-c t" . vterm)
         ("C-c v" . vterm-other-window)))

;; ----------------------------
;; Editing Enhancements
;; ----------------------------
;; Move lines/regions up and down
(use-package move-text
  :bind (("M-<up>" . move-text-up)
         ("M-<down>" . move-text-down)))

;; Multiple cursors
(use-package multiple-cursors
  :bind (("C-c m l" . mc/edit-lines)
         ("C-c m n" . mc/mark-next-like-this)
         ("C-c m p" . mc/mark-previous-like-this)
         ("C-c m a" . mc/mark-all-dwim)
         ("C-c m s" . mc/skip-to-next-like-this)
         ("C-c m b" . mc/skip-to-previous-like-this)))

;; Window management
(use-package ace-window
  :bind (("M-o" . ace-window))
  :custom
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

;; ----------------------------
;; Help System Enhancement
;; ----------------------------
(use-package helpful
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)
         ("C-c h" . helpful-at-point)))

;; ----------------------------
;; Which-key - Display Keybindings
;; ----------------------------
(use-package which-key
  :init
  (which-key-mode)
  :custom
  (which-key-idle-delay 0.5)
  (which-key-sort-order 'which-key-key-order-alpha)
  :config
  (which-key-add-key-based-replacements
    "C-c c" "extra"
    "C-c l" "lsp-extra"
    "C-c m" "multi-cursor"
    "C-c y" "snippets"
    "C-c ?" "cheatsheet"))

;;; tools.el ends here
