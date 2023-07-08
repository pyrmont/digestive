(declare-project
  :name "digestive"
  :description "Digest text"
  :version "0.0.1-dev"
  :author "Michael Camilleri"
  :license "MIT"
  :url "https://github.com/pyrmont/digestive"
  :repo "git+https://github.com/pyrmont/digestive"
  :dependencies []
  :dev-dependencies ["https://github.com/pyrmont/testament"])


(declare-source
  :source ["digestive/bitops.janet"
           "digestive/md5.janet"])


(task "dev-deps" []
  (if-let [deps ((dyn :project) :dependencies)]
    (each dep deps
      (bundle-install dep))
    (do
      (print "no dependencies found")
      (flush)))
  (if-let [deps ((dyn :project) :dev-dependencies)]
    (each dep deps
      (bundle-install dep))
    (do
      (print "no dev-dependencies found")
      (flush))))
