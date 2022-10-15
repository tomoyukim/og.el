;;; og.el --- Get Open Graph data in a web page. -*- lexical-binding: t; -*-

;; Copyright (C) 2022 tomoyukim.

;; Author: Murakami Tomoyuki <tomoyukim@outlook.com>
;; Created: 2022-10-15
;; Version: 0.1.0
;; Package-Version: 20221015.1
;; Keywords: open-graph ogp
;; Package-Requires: ((emacs "24.4") (request "0.3.2"))
;; URL: https://github.com/tomoyukim/og.el

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides a function to get Open Graph data in a web page.

;;; Change Log:

;; 2022-10-15 - v0.1.0
;; * first version. Provides og-get.

;;; code
(require 'cl-lib)
(require 'request)

(defgroup og nil
  "Get Open Graph data in a web page."
  :group 'emacs
  :prefix "og-")

(defun og--parse-og (nodes)
  (let ((hash (make-hash-table :test 'equal)))
    (dolist (node nodes)
      (let ((prop (xml-get-attribute-or-nil node 'property))
            (content (xml-get-attribute-or-nil node 'content)))
        (if (and prop (string-match "^og:.+" prop))
            (puthash prop content hash))))
    hash))

(defun og-get (url)
  "Get a hash table of Open Graph data."
  (let ((ogp nil))
    (request url
      :sync t
      ;; Parse HTML in response body:
      :parser (lambda () (libxml-parse-html-region (point) (point-max)))
      :success (cl-function
                (lambda (&key data &allow-other-keys)
                  (let* ((head (first (xml-get-children data 'head)))
                         (child-meta (xml-get-children head 'meta)))
                    (setq ogp (og--parse-og child-meta))))))
    ogp))

(provide 'og)
