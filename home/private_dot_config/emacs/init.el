;;; init.el --- Bootstrap and load literate config -*- lexical-binding: t; -*-

;;; Commentary:
;; This file does three things:
;;   1. Bootstrap the elpaca package manager
;;   2. Set up use-package integration
;;   3. Tangle and load config.org
;;
;; All real configuration lives in config.org.  Edit that file, not this one.

;;; Code:

;; ------------------------------------------------------------------
;; Elpaca Bootstrap
;; ------------------------------------------------------------------
;; Elpaca is a modern, async package manager.  This installer block is
;; taken from the official docs and will self-install on first launch.

(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; ------------------------------------------------------------------
;; use-package integration
;; ------------------------------------------------------------------
;; This makes every `use-package' declaration automatically go through
;; elpaca for installation.  You can override per-package with :ensure nil
;; for built-in packages.

(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode))

;; Block until elpaca-use-package is installed and activated.
;; Without this, use-package declarations in config.org will run
;; before elpaca-use-package-mode is active, so they won't know
;; to install packages through elpaca.
(elpaca-wait)

;; ------------------------------------------------------------------
;; Load literate config
;; ------------------------------------------------------------------
;; Tangle config.org → config.el, then load it.  The tangled .el is
;; cached; org-babel only re-tangles when the .org is newer.

(defun my/load-literate-config ()
  "Tangle and load config.org if it is newer than config.el."
  (let* ((config-org (expand-file-name "config.org" user-emacs-directory))
         (config-el  (expand-file-name "config.el"  user-emacs-directory)))
    (when (file-exists-p config-org)
      (if (and (file-exists-p config-el)
               (time-less-p (file-attribute-modification-time
                             (file-attributes config-org))
                            (file-attribute-modification-time
                             (file-attributes config-el))))
          ;; config.el is up to date — just load it
          (load-file config-el)
        ;; Tangle config.org → config.el, then load
        (require 'org)
        (org-babel-tangle-file config-org config-el)
        (load-file config-el)))))

(my/load-literate-config)

;;; init.el ends here