(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)


;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa")
			 ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(use-package use-package
  :custom
  (use-package-always-ensure t)
  (package-native-compile t)
  (warning-minimum-level :emergency))

(use-package diminish :ensure t)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

;; Evil
(use-package general
  :after evil
  :config
  (general-create-definer efs/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (efs/leader-keys
    "t"  '(:ignore t :which-key "toggles")))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  
  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))


;; Setup ivy
(use-package ivy
        :demand t
        :diminish
	:bind (("C-s" . swiper)
		:map ivy-minibuffer-map
		("TAB" . ivy-alt-done)
		("C-l" . ivy-alt-done)
		("C-j" . ivy-next-line)
		("C-k" . ivy-previous-line)
		:map ivy-switch-buffer-map
		("C-k" . ivy-previous-line)
		("C-l" . ivy-done)
		("C-d" . ivy-switch-buffer-kill)
		:map ivy-reverse-i-search-map
		("C-k" . ivy-previous-line)
		("C-d" . ivy-reverse-i-search-kill))
	:config
	(ivy-mode 1))
 
(column-number-mode)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  ;; Uncomment the following line to have sorting remembered across sessions!
  ;(prescient-persist-mode 1)
  (ivy-prescient-mode 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpul-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package hydra
  :defer t)

 ;; Remember and restore the last cursor location of opened files
(save-place-mode 1)

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projetile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (setq projectile-switch-project-action #'projectile-dired)
  )

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-bufer-same-window-except-diff-v1))

(use-package forge)

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (visual-line-mode 1)
  )

;; Check spelling with flyspell and hunspell

(use-package flyspell
  :custom
  (ispell-program-name "hunspell")
  (ispell-dictionary "en_GB")
  (flyspell-mark-duplications-flag nil) ;; Writegood mode does this
  (org-fold-core-style 'overlays) ;; Fix Org mode bug
  :config
  (ispell-set-spellchecker-params)
  :hook
  (text-mode . flyspell-mode)
  :bind
  (("C-c w s s" . ispell)
   ("C-;"       . flyspell-auto-correct-previous-word)))

(use-package writegood-mode
  :bind
  (("C-c w s r" . writegood-reading-ease)
   ("C-c w s l" . writegood-grade-level))
  :hook
  (text-mode . writegood-mode))

(use-package org
  :pin org
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-hide-emphasis-markers t)
  :custom
  (org-export-with-drawers nil)
  (org-export-with-todo-keywords nil)
  (org-export-with-broken-links t)
  (org-export-with-toc nil)
  (org-export-with-smart-quotes t)
  (org-export-date-timestamp-format "%e %B %Y")
  )

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 70
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

;; Read ePub files

(use-package nov
  :init
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

;; epub export

(use-package ox-epub
  :demand t
  :init
  (require 'ox-org))

;; LaTeX PDF Export settings

(use-package ox-latex
  :ensure nil
  :demand t
  :custom
  ;; Multiple LaTeX passes for bibliographies
  (org-latex-pdf-process
   '("pdflatex -interaction nonstopmode -output-directory %o %f"
     "bibtex %b"
     "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
     "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
  ;; Clean temporary files after export
  (org-latex-logfiles-extensions
   (quote ("lof" "lot" "tex~" "aux" "idx" "log" "out"
           "toc" "nav" "snm" "vrb" "dvi" "fdb_latexmk"
           "blg" "brf" "fls" "entoc" "ps" "spl" "bbl"
           "tex" "bcf"))))

;; EWS paperback configuration

(with-eval-after-load 'ox-latex
  (add-to-list
   'org-latex-classes
   '("ews"
     "\\documentclass[11pt, twoside]{memoir}
      \\setstocksize{9.25in}{7.5in}
      \\settrimmedsize{\\stockheight}{\\stockwidth}{*}
      \\setlrmarginsandblock{2cm}{1cm}{*} 
      \\setulmarginsandblock{1.5cm}{2.25cm}{*}
      \\checkandfixthelayout
      \\setcounter{tocdepth}{0}
      \\OnehalfSpacing
      \\usepackage{ebgaramond}
      \\usepackage[htt]{hyphenat}
      \\chapterstyle{bianchi}
      \\setsecheadstyle{\\normalfont \\raggedright \\textbf}
      \\setsubsecheadstyle{\\normalfont \\raggedright \\textbf}
      \\setsubsubsecheadstyle{\\normalfont\\centering}
      \\usepackage[font={small, it}]{caption}
      \\pagestyle{myheadings}
      \\usepackage{ccicons}
      \\usepackage[authoryear]{natbib}
      \\bibliographystyle{apalike}
      \\usepackage{svg}"
     ("\\chapter{%s}" . "\\chapter*{%s}")
     ("\\section{%s}" . "\\section*{%s}")
     ("\\subsection{%s}" . "\\subsection*{%s}")
     ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))))

;; Forces the messages to 0, and kills the *Messages* buffer - thus disabling it on startup.
(setq-default message-log-max nil)
(setq-default comp-async-report-warning-errors nil)
(kill-buffer "*Messages*")

;; Function to create a custom display table
(defun my-custom-display-table ()
  (let ((table (make-display-table)))
    ;; Define the mappings for Unicode characters
    (aset table 8211 (vector ?-))     ; En dash to -
    (aset table 8212 (vector ?- ?-))  ; Em dash to --
    (aset table 8216 (vector ?'))     ; Left single quotation mark to '
    (aset table 8217 (vector ?'))     ; Right single quotation mark to '
    (aset table 8220 (vector ?\"))    ; Left double quotation mark to "
    (aset table 8221 (vector ?\"))    ; Right double quotation mark to "
    (aset table 8230 (string-to-multibyte "...")) ; Ellipsis to ..  
    (aset table 2026 (string-to-multibyte "...")) ; Unicode ellipsis (U+2026) to ...
    (aset table (make-char 'unicode 8211) (vector ?-))       ; En dash followed by '
    (aset table (make-char 'unicode 8212) (vector ?- ?-))    ; Em dash followed by '
    (aset table (make-char 'unicode 8230) (string-to-multibyte "...")) ; Ellipsis followed by '
    (aset table (make-char 'unicode 2026) (string-to-multibyte "...")) ; Ellipsis followed b\
y '  
    (aset table (make-char 'unicode 8211) (vector ?- ?'))     ; En dash followed by "
    (aset table (make-char 'unicode 8212) (vector ?- ?- ?'))  ; Em dash followed by "
    (aset table (make-char 'unicode 8230) (string-to-multibyte "...")) ; Ellipsis followed by "
    (aset table (make-char 'unicode 2026) (string-to-multibyte "...")) ; Ellipsis followed b\
y "   
   table))

;; Function to set the custom display table for all buffers
(defun my-set-display-table-for-all-buffers ()
  (setq-default buffer-display-table (my-custom-display-table))
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (setq buffer-display-table (my-custom-display-table)))))

;; Apply the custom display table when Emacs starts and for new buffers
(my-set-display-table-for-all-buffers)
(add-hook 'after-change-major-mode-hook 'my-set-display-table-for-all-buffers)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ivy-prescient evil-collection evil auto-package-update which-key wc-mode smart-mode-line rainbow-delimiters ivy-rich helpful general doom-modeline diminish counsel))
 '(warning-suppress-log-types '((comp) (comp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
