;; 起動メッセージを非表示
(setq inhibit-startup-message t)

;; C-h で Backspace
(keyboard-translate ?\C-h ?\C-?)

;; C-o で IME 切り替え
(global-set-key (kbd "C-o") 'toggle-input-method)

;; C-S-tab でタブを切り替え
;; init.el の設定を再変更
(global-set-key (kbd "<C-S-tab>") 'tabbar-backward-tab)

;; C-q C-m <CR>, C-q C-j <LF> での入力を可能にする
;; init.el の設定を再変更
(global-set-key (kbd "C-q") 'quoted-insert)

;; カーソル行をハイライト
(global-hl-line-mode t)

;; 矩形選択
(cua-mode t)
(setq cua-enable-cua-keys nil) ; デフォルトキーバインドを無効化
(define-key global-map (kbd "C-x SPC") 'cua-set-rectangle-mark)

;; タブ幅設定用関数
;; https://masutaka.net/chalow/2009-07-10-4.html
(defun set-aurora-tab-width (num &optional local redraw)
  "タブ幅をセットします。タブ5とかタブ20も設定できたりします。
localが non-nilの場合は、カレントバッファでのみ有効になります。
redrawが non-nilの場合は、Windowを再描画します。"
  (interactive "nTab Width: ")
  (when local
    (make-local-variable 'tab-width)
    (make-local-variable 'tab-stop-list))
  (setq tab-width num)
  (setq tab-stop-list ())
  (while (<= num 256)
    (setq tab-stop-list `(,@tab-stop-list ,num))
    (setq num (+ num tab-width)))
  (when redraw (redraw-display)) tab-width)

(set-aurora-tab-width (setq default-tab-width (setq-default tab-width 4)))
(setq indent-tabs-mode nil)


;; ======================================================================
;;                                 El-Get
;;
;; Caskはもう古い、これからはEl-Get - いまどきのEmacsパッケージ管理
;; http://tarao.hatenablog.com/entry/20150221/1424518030#tips-byte-compilation
;;
;; ======================================================================
(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

(add-to-list 'load-path (locate-user-emacs-file "el-get/el-get"))
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(el-get-bundle tarao/with-eval-after-load-feature-el)


;; ------------------------------ use-package ------------------------------
(el-get-bundle use-package
  (require 'use-package)
  )


;; ------------------------------ whitespace ------------------------------
(el-get-bundle whitespace
  (require 'whitespace)
  ;; 色の指定は M-x: list-faces-display から行う

  (setq whitespace-space-regexp "\\([\x0020\x3000]+\\)" )

  (setq whitespace-style
        '(face
          tabs
          tab-mark
          spaces
          space-mark
          newline
          newline-mark
          trailing))

  (setq whitespace-display-mappings
        '((space-mark   ?\    [?\xB7])
          (space-mark   ?\x3000    [?\□])
          (newline-mark ?\n   [?\↲ ?\n] )
          ;; WARNING: the mapping below has a problem.
          ;; When a TAB occupies exactly one column, it will display the
          ;; character ?\xBB at that column followed by a TAB which goes to
          ;; the next TAB column.
          ;; If this is a problem for you, please, comment the line below.
          ;; (tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])
          ))

  (setq whitespace-line-column 85)
  (global-whitespace-mode 1)
  )


;; ------------------------------ web-mode ------------------------------
(el-get-bundle web-mode
  (require 'web-mode)
  (add-to-list 'auto-mode-alist '("\\.jsp$"       . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?$"     . web-mode))
  (defun web-mode-indent (num)
    (interactive "nIndent: ")
    (setq web-mode-markup-indent-offset num)
    (setq web-mode-css-indent-offset num)
    (setq web-mode-style-padding num)
    (setq web-mode-code-indent-offset num)
    (setq web-mode-script-padding num)
    (setq web-mode-block-padding num)
    )

  ;; http://qiita.com/hayamiz/items/130727c09230fab0c097
  (defun my-web-mode-hook ()
    "Hooks for Web mode."
    (web-mode-indent 2)
    (setq indent-tabs-mode nil)

    (local-set-key (kbd "C-m") 'newline-and-indent)
    (local-set-key (kbd "RET") 'newline-and-indent)

    ;; auto tag closing
    ;; 0=no auto-closing
    ;; 1=auto-close with </
    ;; 2=auto-close with > and </
    (setq web-mode-auto-close-style 1)
    )
  (add-hook 'web-mode-hook 'my-web-mode-hook)
  )


;; ------------------------------ yasnippet ------------------------------
;; http://www-he.scphys.kyoto-u.ac.jp/member/shotakaha/dokuwiki/doku.php?id=toolbox:emacs:yasnippet:start
;;
;; yasnippet を MELPA からインストールする
;; モードラインには非表示（:diminish yas-minor-mode）
;; 個人スニペット用ディレクトリ（~/.emacs.d/snippet/）を作成する
;; スニペット選択（yas-prompt-functions）は、デフォルトでたくさんの方法がリストされてるが、Idoだけを使うように変更
;; キーバインドを「挿入（C-x i）」系に割り当てる
;;
;; ＜佐藤メモ＞
;; use-package を使うと「yas-global-mode t」がどうもうまくいかない
;; 「:ensure t」を設定すると ruby 等の snippet も読み込んでくれるのだが、
;; use-package と el-get ではダウンロード先のディレクトリが異なるので、 use-package の方（site-lisp）は一旦削除した
(el-get-bundle yasnippet
  (require 'yasnippet)
  (define-key yas-minor-mode-map (kbd "C-x i i") 'yas-insert-snippet)
  (define-key yas-minor-mode-map (kbd "C-x i n") 'yas-new-snippet)
  (define-key yas-minor-mode-map (kbd "C-x i v") 'yas-visit-snippet-file)
  (define-key yas-minor-mode-map (kbd "C-x i l") 'yas-describe-tables)
  (define-key yas-minor-mode-map (kbd "C-x i g") 'yas-reload-all)
  (setq yas-prompt-functions '(yas-ido-prompt))
  (yas-global-mode 1)
  )

;; ------------------------------ csv-mode ------------------------------
(el-get-bundle csv-mode)



;; ------------------------------ evil ------------------------------
;; 日本語入力に難があるため、殆ど使わないかもしれない
;; C-z で解除可能
(use-package evil
  :ensure t
  :config
  (evil-mode 0)
  )
;; http://makble.com/how-to-toggle-evil-mode-in-emacs
(defun toggle-evilmode ()
  (interactive)
  (if (bound-and-true-p evil-local-mode)
    (progn
      ; go emacs
      (evil-local-mode (or -1 1))
      (undo-tree-mode (or -1 1))
      (set-variable 'cursor-type 'bar)
    )
    (progn
      ; go evil
      (evil-local-mode (or 1 1))
      (set-variable 'cursor-type 'box)
    )
  )
)
(global-set-key (kbd "C-z") 'toggle-evilmode)


;; ------------------------------ eww-mode ------------------------------
(use-package eww
  :config
  (setq eww-search-prefix "http://www.google.co.jp/search?q=")
  :bind
  (("M-h" . eww-back-url)
   ("M-l" . eww-forward-url)
  ));



;; ------------------------------ sanityinc-tomorrow ------------------------------
(el-get-bundle color-theme-sanityinc-tomorrow)
; (color-theme-sanityinc-tomorrow-blue)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; モードラインのフォント
;;; M-x describe-face mode[TAB] でいろいろ出てくる。
;; モードライン
; (set-face-font 'mode-line "Rounded Mgen+ 2m regular-12")
; ;; 非アクティブなウィンドウのモードライン
; (set-face-font 'mode-line-inactive "Rounded Mgen+ 2m regular-10")
; ;; バッファ名
; (set-face-font 'mode-line-buffer-id "Rounded Mgen+ 2m regular-12")
;
; Options > Customize Emacs > Browse Customization Groups > Face グループから「Mode line」関係の設定を変更する




;; ======================================================================
;;                       emacs options
;; ======================================================================

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["black" "#d55e00" "#009e73" "#f8ec59" "#0072b2" "#cc79a7" "#56b4e9" "white"])
 '(background-color "#fdf6e3")
 '(background-mode light)
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(cua-mode t nil (cua-base))
 '(cursor-color "#657b83")
 '(custom-enabled-themes (quote (tsdh-dark)))
 '(custom-safe-themes
   (quote
	("1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" "fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6" "1d1c7afb6cbb5a8a8fb7eb157a4aaf06805215521c2ab841bd2c4a310ce3781e" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" default)))
 '(fci-rule-color "#424242")
 '(foreground-color "#657b83")
 '(package-selected-packages (quote (evil csv-mode)))
 '(show-paren-mode t)
 '(tabbar-mode t nil (tabbar))
 '(tool-bar-mode nil)
 '(tooltip-mode nil)
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
	((20 . "#d54e53")
	 (40 . "#e78c45")
	 (60 . "#e7c547")
	 (80 . "#b9ca4a")
	 (100 . "#70c0b1")
	 (120 . "#7aa6da")
	 (140 . "#c397d8")
	 (160 . "#d54e53")
	 (180 . "#e78c45")
	 (200 . "#e7c547")
	 (220 . "#b9ca4a")
	 (240 . "#70c0b1")
	 (260 . "#7aa6da")
	 (280 . "#c397d8")
	 (300 . "#d54e53")
	 (320 . "#e78c45")
	 (340 . "#e7c547")
	 (360 . "#b9ca4a"))))
 '(vc-annotate-very-old-color nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Rounded Mgen+ 2m regular" :foundry "outline" :slant normal :weight normal :height 120 :width normal))))
 '(mode-line ((t (:background "gray30" :box (:line-width 1 :color "red") :slant normal :weight normal :height 120 :width normal :foundry "outline" :family "Rounded Mgen+ 2m regular"))))
 '(mode-line-buffer-id ((t (:slant normal :weight normal :height 120 :width normal :foundry "outline" :family "Rounded Mgen+ 2m regular"))))
 '(mode-line-inactive ((t (:inherit mode-line :foreground "dark gray" :slant normal :weight normal :height 98 :width normal :foundry "outline" :family "Rounded Mgen+ 2m regular"))))
 '(org-block-background ((t (:foreground "black"))))
 '(org-indent ((t (:foreground "black"))) t)
 '(whitespace-newline ((t (:foreground "black"))))
 '(whitespace-space ((t (:background "grey20" :foreground "black")))))
