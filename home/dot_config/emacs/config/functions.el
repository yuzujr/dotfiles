;;; functions.el -*- lexical-binding: t; -*-
(provide 'functions)

(defun rc/duplicate-line ()
  "Duplicate current line"
  (interactive)
  (let ((column (- (point) (point-at-bol)))
        (line (let ((s (thing-at-point 'line t)))
                (if s (string-remove-suffix "\n" s) ""))))
    (move-end-of-line 1)
    (newline)
    (insert line)
    (move-beginning-of-line 1)
    (forward-char column)))

(defconst rc/cheatsheet-file
  (expand-file-name "CHEATSHEET.md" user-emacs-directory)
  "Path to the local Emacs keybinding cheatsheet.")

(defun rc/protect-cheatsheet-buffer ()
  "Open the cheatsheet buffer in read-only mode to avoid accidental edits."
  (when (and buffer-file-name
             (file-equal-p (file-truename buffer-file-name)
                           (file-truename rc/cheatsheet-file)))
    (read-only-mode 1)
    (view-mode 1)))

(defun rc/open-cheatsheet ()
  "Open the local Emacs keybinding cheatsheet."
  (interactive)
  (find-file rc/cheatsheet-file)
  (rc/protect-cheatsheet-buffer))

(global-set-key (kbd "C-,") #'rc/duplicate-line)
(global-set-key (kbd "C-c ?") #'rc/open-cheatsheet)
