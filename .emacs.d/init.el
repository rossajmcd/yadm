;; -*- lexical-binding: t; -*-

;; TODO: remove manual dependencies
;; - emacs-libvterm (see github cloned and built locally and included via add-to-list loadpath
;;   - I did not find a way yet to have CC=gcc set for an auto build of vterm in emacs


;; You will most likely need to adjust this font size for your system!
(defvar efs/default-font-size 180)
(defvar efs/default-variable-font-size 180)

;; Make frame transparency overridable
(defvar efs/frame-transparency '(95 . 95))

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("nongnu" . "https://elpa.nongnu.org/nongnu/") 
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

(setq make-backup-files nil)

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

(column-number-mode)
(global-display-line-numbers-mode t)

;; Set frame transparency
(set-frame-parameter (selected-frame) 'alpha efs/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,efs/frame-transparency))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(defun dashboard-insert-custom (list-size)
  (dashboard-insert-heading "Help:"
                            nil
                            (all-the-icons-faicon "newspaper-o"
                                                  :height 1.2
                                                  :v-adjust 0.0
                                                  :face 'dashboard-heading))
  (insert "\n")
  (insert "    C-TAB = cycle through workspace tabs")
  (insert "\n")
  (insert "    C-c TAB b = list buffers in a workspace")
  (insert "\n")
  (insert "    C-c TAB s = switch to tabspaces workspace")
  (insert "\n")
  (insert "    C-c n n and specify 'home' to open the Exobrain home note")
  (insert "\n")
  (insert "    C-c n j = create a journal for today with Denote"))

(setq dashboard-startup-banner "~/.emacs.d/emacs.png")

(setq dashboard-icon-type 'all-the-icons)
(setq dashboard-set-navigator t)

(setq dashboard-items '((recents  . 10)
                        (bookmarks . 10)
                        (projects . 5)
                        (agenda . 5)
                        (registers . 5)))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))

(add-to-list 'dashboard-item-generators  '(custom . dashboard-insert-custom))
(add-to-list 'dashboard-items '(custom) t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;(set-face-attribute 'default nil :font "Fira Code Regular" :height efs/default-font-size)

;; Set the fixed pitch face
;(set-face-attribute 'fixed-pitch nil :font "Fira Code Regular" :height efs/default-font-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height efs/default-variable-font-size :weight 'regular)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package command-log-mode
  :commands command-log-mode)

(use-package doom-themes
  :init (load-theme 'doom-palenight t))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

(use-package ivy
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

(use-package ivy-rich
  :after ivy
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
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(defun my-denote-journal ()
  "Create an entry tagged 'journal' with the date as its title."
  (interactive)
  (denote-journal-extras-new-entry)
  (insert "* Personal log\n\n* Professional log\n\n* Bookmarks log\n\n* Discoveries log\n\n* Stoic log\n\n"))

(use-package denote
    :init
    (require 'denote-org-dblock)
    (require 'denote-journal-extras)
    (denote-rename-buffer-mode t)
    :custom
    (denote-directory "~/Sync/vaults/SecondBrainDisk/Documents/mine/Denote")
    :hook
    (dired-mode . denote-dired-mode)
    :custom-face
    (denote-faces-link ((t (:slant italic))))
    :bind
    (("C-c n n" . denote-create-note)
     ("C-c n d" . denote-date)
     ("C-c n j" . my-denote-journal)
     ("C-c n i" . denote-link-or-create)
     ("C-c n l" . denote-find-link)
     ("C-c n b" . denote-find-backlink)
     ("C-c n d" . denote-org-dblock-insert-links)
     ("C-c n r" . denote-rename-file)
     ("C-c n R" . denote-rename-file-using-front-matter)
     ("C-c n k" . denote-keywords-add)
     ("C-c n K" . denote-keywords-remove)))

(use-package tabspaces
  :hook (after-init . tabspaces-mode) ;; use this only if you want the minor-mode loaded at startup. 
  :commands (tabspaces-switch-or-create-workspace
             tabspaces-open-or-create-project-and-workspace)
  :custom
  (tabspaces-use-filtered-buffers-as-default t)
  (tabspaces-default-tab "Dashboard")
  (tabspaces-remove-to-default t)
  (tabspaces-include-buffers '("*scratch*"))
  ;(tabspaces-initialize-project-with-todo t)
  ;(tabspaces-todo-file-name "project-todo.org")
  ;; sessions
  (tabspaces-session t)
  (tabspaces-session-auto-restore t))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

;; The buffer you put this code in must have lexical-binding set to t!
;; See the final configuration at the end for more details.
(require 'org-roam-node)
(defun my/org-roam-filter-by-tag (tag-name)
  (lambda (node)
    (member tag-name (org-roam-node-tags node))))

(defun my/org-roam-list-notes-by-tag (tag-name)
  (mapcar #'org-roam-node-file
          (seq-filter
           (my/org-roam-filter-by-tag tag-name)
           (org-roam-node-list))))

(defun my/org-roam-refresh-agenda-list ()
  (interactive)
  (setq org-agenda-files (my/org-roam-list-notes-by-tag "Project")))

;; Build the agenda list the first time for the session
(my/org-roam-refresh-agenda-list)

(defun personal-note (ntype)
  (cond
    ((string= 'daily ntype) (concat "~/Sync/vaults/SecondBrainDisk/Documents/mine/OrgFiles" (format-time-string "/%Y/%B_%-e.org")))
    (t (error "Invalid personal note type: " ntype))))

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-agenda-files
        '("~/Sync/vaults/SecondBrainDisk/Documents/mine/OrgFiles/Tasks.org"
          "~/Sync/vaults/SecondBrainDisk/Documents/mine/OrgFiles/Habits.org"
          "~/Sync/vaults/SecondBrainDisk/Documents/mine/OrgFiles/Birthdays.org"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
    '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
      (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

   (setq org-refile-targets
    '(("20240124T082315--archive__archive.org" :maxlevel . 1)
      ("Tasks.org" :maxlevel . 1)
      ("20240124T101153--books__books.org" :maxlevel . 1)
      ("20240124T110508--games__games.org" :maxlevel . 1)
      ("20240124T095417--watchlist__watchlist.org" :maxlevel . 1)
      ("20240124T110034--movies__movies.org" :maxlevel . 1)
      ("20240124T110820--series__series.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work" . ?W)
       ("bitek" . ?B)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("publish" . ?P)
       ("batch" . ?b)
       ("note" . ?n)
       ("idea" . ?i)
       ("r0ss" . ?r)
       ("voxmachina" . ?v)
       ("CabinetOffice" . ?c)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
   '(("d" "Dashboard"
     ((agenda "" ((org-deadline-warning-days 7)))
      (todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))
      (tags "Project/TODO" ((org-agenda-overriding-header "Active Projects")
				   (org-agenda-files (my/org-roam-refresh-agenda-list))
				  ;(my/org-roam-refresh-agenda-list)
				  ))))

    ("n" "Next Tasks"
     ((todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))))

    ("W" "Work Tasks" tags-todo "+work-email")

    ;; Low-effort next actions
    ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
     ((org-agenda-overriding-header "Low Effort Tasks")
      (org-agenda-max-todos 20)
      (org-agenda-files org-agenda-files)))

    ("w" "Workflow Status"
     ((todo "WAIT"
            ((org-agenda-overriding-header "Waiting on External")
             (org-agenda-files org-agenda-files)))
      (todo "REVIEW"
            ((org-agenda-overriding-header "In Review")
             (org-agenda-files org-agenda-files)))
      (todo "PLAN"
            ((org-agenda-overriding-header "In Planning")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "BACKLOG"
            ((org-agenda-overriding-header "Project Backlog")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "READY"
            ((org-agenda-overriding-header "Ready for Work")
             (org-agenda-files org-agenda-files)))
      (todo "ACTIVE"
            ((org-agenda-overriding-header "Active Projects")
             (org-agenda-files org-agenda-files)))
      (todo "COMPLETED"
            ((org-agenda-overriding-header "Completed Projects")
             (org-agenda-files org-agenda-files)))
      (todo "CANC"
            ((org-agenda-overriding-header "Cancelled Projects")
             (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "~/Sync/vaults/SecondBrainDisk/Documents/mine/OrgFiles/Tasks.org" "Inbox")
       "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)
      
       ("l" "Links" entry
        (file+headline (lambda () (personal-note 'daily)) "Bookmarks")
        "** %(org-cliplink-capture)%?\n" :unnarrowed t)

      ("d" "Discover" entry
       (file+headline (lambda () (personal-note 'daily)) "Discoveries")
       "* %?\n :discovery: %U\n  %a\n  %i" :empty-lines 1)

       ("y" "Watchlist" entry (file+headline "~/Sync/vaults/SecondBrainDisk/Documents/mine/OrgFiles/watchlist.org" "Inbox")
           "** TODO %(org-cliplink-capture)%?\n" :unnarrowed t)

      ("j" "Journal Entries")
      ("jp" "Professional journal" entry
       (file+headline (lambda () (personal-note 'daily)) "Professional journal")
p       "* %? :journal:professional:\n  %U\n  %a\n  %i" :empty-lines 1)
      ("jm" "Personal journal" entry
       (file+headline (lambda () (personal-note 'daily)) "Personal journal")
       "* %? :journal:personal:\n  %U\n  %a\n  %i" :empty-lines 1)

      ("w" "Workflows")
      ("we" "Checking Email" entry (file+olp+datetree "~/Sync/vaults/SecondBrainDisk/Documents/mine/OrgFiles/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

      ("m" "Metrics Capture")
      ("mw" "Weight" table-line (file+headline "~/Sync/vaults/SecondBrainDisk/Documents/mine/OrgFiles/Metrics.org" "Weight")
       "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))

  (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))

  (efs/org-font-setup))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

(with-eval-after-load 'org
  (org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
      (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/Sync/vaults/SecondBrainDisk/Documents/mine/RoamFiles")
  (org-roam-completion-everywhere t)
  ; removed while debugging the inability to create new roam nodes (which are overidden) (org-roam-completion-system 'default)
  (org-roam-capture-templates
    '(("d" "default" plain
      "%?"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
      ("p" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
       :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+category: ${title}\n#+filetags: Project")
       :unnarrowed t)))
  (org-roam-dailies-capture-templates
    '(("l" "Log" entry "** %?\n :Log: %U\n  %a\n  %i"
       :target (file+olp "%<%Y-%m-%d>.org" ("Log"))
       "* %?")
      
      ("j" "Journal entries")
      ("jm" "Personal journal" entry "** %?\n :PersonalJournal: %U\n  %a\n  %i"
       :target (file+olp "%<%Y-%m-%d>.org" ("Personal journal"))
       "* %?")
      ("jp" "Professional journal" entry "** %?\n :ProfessionalJournal: %U\n  %a\n  %i"
       :target (file+olp "%<%Y-%m-%d>.org" ("Professional journal"))
       "* %?")
      
      ("b" "Bookmark" entry "** %?\n :Bookmark: %U\n  %a\n  %i"
       :target (file+olp "%<%Y-%m-%d>.org" ("Bookmarks"))
       "* %?")
      ("d" "Discovery" entry "** %?\n :Discovery: %U\n  %a\n  %i"
       :target (file+olp "%<%Y-%m-%d>.org" ("Discoveries"))
       "* %?")

      ("f" "Finance entries")
      ("fs" "Finance subscription" entry "** %?\n :Financial:Subscription: %U\n  %a\n  %i"
       :target (file+olp "%<%Y-%m-%d>.org" ("Financial subscription"))
       " * %?")
      ("fd" "Finance digital purchase" entry "** %?\n :Financial:DigitalPurchase: %U\n  %a\n  %i"
       :target (file+olp "%<%Y-%m-%d>.org" ("Financial digital purchase"))
       " * %?")
      ("fp" "Finance purchase" entry "** %?\n :Financial:Purchase: %U\n  %a\n  %i"
       :target (file+olp "%<%Y-%m-%d>.org" ("Financial purchase"))
       " * %?")))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
	       :map org-roam-mode-map
	       (("C-c n c"   . org-roam-dailies-capture-today))
         :map org-mode-map
         ("C-M-i" . completion-at-point)
         :map org-roam-dailies-map
         ("Y" . org-roam-dailies-capture-yesterday)
         ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies) ;; Ensure the keymap is available
  (org-roam-db-autosync-mode))

;; Automatically tangle our Emacs.org config file when we save it
(defun efs/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)

(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)
  :commands dap-debug
  :config
  ;; Set up Node debugging
  (require 'dap-node)
  (dap-node-setup) ;; Automatically installs Node debug adapter if needed

  ;; Bind `C-c l d` to `dap-hydra` for easy access
  (general-define-key
    :keymaps 'lsp-mode-map
    :prefix lsp-keymap-prefix
    "d" '(dap-hydra t :wk "debugger")))

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2))

(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :custom
  ;; NOTE: Set these if Python 3 is called "python3" on your system!
  ;; (python-shell-interpreter "python3")
  ;; (dap-python-executable "python3")
  (dap-python-debugger 'debugpy)
  :config
  (require 'dap-python))

(use-package pyvenv
  :after python-mode
  :config
  (pyvenv-mode 1))

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package term
  :commands term
  :config
  (setq explicit-shell-file-name "bash") ;; Change this to zsh, etc
  ;;(setq explicit-zsh-args '())         ;; Use 'explicit-<shell>-args for shell-specific args

  ;; Match the default Bash shell prompt.  Update this if you have a custom prompt
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"))

(use-package eterm-256color
  :hook (term-mode . eterm-256color-mode))

(add-to-list 'load-path "/home/r0ss/Dependencies/emacs-libvterm")

(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))

(when (eq system-type 'windows-nt)
  (setq explicit-shell-file-name "powershell.exe")
  (setq explicit-powershell.exe-args '()))

(defun efs/configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt
  :after eshell)

(use-package eshell
  :hook (eshell-first-time-mode . efs/configure-eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first")))

(use-package dired-single
  :commands (dired dired-jump))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(ednc-mode 1)

(defun show-notification-in-buffer (old new)
  (let ((name (format "Notification %d" (ednc-notification-id (or old new)))))
    (with-current-buffer (get-buffer-create name)
      (if new (let ((inhibit-read-only t))
                (if old (erase-buffer) (ednc-view-mode))
                (insert (ednc-format-notification new t))
                (pop-to-buffer (current-buffer)))
        (kill-buffer)))))

(add-hook 'ednc-notification-presentation-functions
          #'show-notification-in-buffer)

(use-package origami
  :hook (clojure-mode . origami-mode))

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(tabspaces dired-hide-dotfiles dired-open all-the-icons-dired dired-single eshell-git-prompt vterm eterm-256color rainbow-delimiters forge magit counsel-projectile projectile company-box company pyvenv python-mode typescript-mode dap-mode lsp-ivy lsp-treemacs lsp-ui lsp-mode visual-fill-column org-bullets exwm which-key no-littering ivy-rich ivy-prescient hydra helpful goto-chg general doom-themes doom-modeline desktop-environment counsel command-log-mode auto-package-update annalist all-the-icons)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(setq ews-music-directory "~/Music")

;; Emacs Multimedia System
(use-package emms
  :init
  (require 'emms-setup)
  ;(require 'emms-mpris)
  (emms-all)
  (emms-default-players)
  ;(emms-mpris-enable)
  :custom
  (emms-source-file-default-directory ews-music-directory)
  (emms-browser-covers #'emms-browser-cache-thumbnail-async)
  :bind
  (("<f5>"   . emms-browser)
   ("M-<f5>" . emms)
   ("<XF86AudioPrev>" . emms-previous)
   ("<XF86AudioNext>" . emms-next)
   ("<XF86AudioPlay>" . emms-pause)))

(use-package mu4e
  :ensure nil
  :config

  ;; This is set to 't' to avoid mail syncing issues when using mbsync
  (setq mu4e-change-filenames-when-moving t)

  ;; Refresh mail using isync every 10 minutes
  (setq mu4e-update-interval (* 10 60))
  (setq mu4e-get-mail-command "mbsync -a -c ~/.config/mbsync/.mbsyncrc")
  (setq mu4e-maildir "~/Mail")

  (setq mu4e-contexts
        (list
         ;; Gmail account
         (make-mu4e-context
          :name "Gmail-rossajmcd"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/Gmail" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "rossajmcd@gmail.com")
                  (user-full-name    . "Ross McDonald")
                  (mu4e-drafts-folder  . "/Gmail/[Gmail]/Drafts")
                  (mu4e-sent-folder  . "/Gmail/[Gmail]/Sent Mail")
                  (mu4e-refile-folder  . "/Gmail/[Gmail]/All Mail")
                  (mu4e-trash-folder  . "/Gmail/[Gmail]/Trash")))

	 ;; rossajmcd Posteo account
         (make-mu4e-context
          :name "1-Posteo-rossajmcd"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/Posteo" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "rossajmcd@posteo.net")
                  (user-full-name    . "rossajmcd")
                  (mu4e-drafts-folder  . "/Posteo/Drafts")
                  (mu4e-sent-folder  . "/Posteo/Sent")
                  (mu4e-refile-folder  . "/Posteo/Archive")
                  (mu4e-trash-folder  . "/Posteo/Trash")))

	 ;; r0ss Posteo account
         (make-mu4e-context
          :name "2-Posteo-r0ss"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/Posteo-r0ss" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "r0ss@posteo.net")
                  (user-full-name    . "r0ss")
                  (mu4e-drafts-folder  . "/Posteo-r0ss/Drafts")
                  (mu4e-sent-folder  . "/Posteo-r0ss/Sent")
                  (mu4e-refile-folder  . "/Posteo-r0ss/Archive")
                  (mu4e-trash-folder  . "/Posteo-r0ss/Trash")))

	 ;; Gmail account
         (make-mu4e-context
          :name "3-Gmail-ee"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/Gmail-ee" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "ross.mcdonald@equalexperts.com")
                  (user-full-name    . "Ross McDonald")
                  (mu4e-drafts-folder  . "/Gmail-ee/[Gmail-ee]/Drafts")
                  (mu4e-sent-folder  . "/Gmail-ee/[Gmail-ee]/Sent Mail")
                  (mu4e-refile-folder  . "/Gmail-ee/[Gmail-ee]/All Mail")
                  (mu4e-trash-folder  . "/Gmail-ee/[Gmail-ee]/Trash")))

	 ))

  (setq mu4e-maildir-shortcuts
        '(("/Gmail/Inbox"             . ?i)
          ("/Gmail/[Gmail]/Sent Mail" . ?s)
          ("/Gmail/[Gmail]/Trash"     . ?t)
          ("/Gmail/[Gmail]/Drafts"    . ?d)
          ("/Gmail/[Gmail]/All Mail"  . ?a))))

(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c l") 'org-cliplink)
(global-set-key (kbd "C-c v") 'mpv-play-url)
(global-set-key (kbd "C-c m") 'emms-pause)

(load-file "~/Sync/vaults/SecondBrainDisk/Projects/.emacs-znc-secret")
