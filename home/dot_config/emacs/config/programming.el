;;; programming.el -*- lexical-binding: t; -*-

(provide 'programming)

;; ----------------------------
;; Tree-sitter
;; ----------------------------
;; Enable tree-sitter for supported modes
(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; ----------------------------
;; Language-specific Modes
;; ----------------------------
(use-package kdl-mode
  :mode ("\\.kdl\\'" . kdl-mode))

(use-package glsl-mode
  :mode ("\\.glsl\\'" . glsl-mode)
        ("\\.vert\\'" . glsl-mode)
        ("\\.frag\\'" . glsl-mode))

;;; programming.el ends here
