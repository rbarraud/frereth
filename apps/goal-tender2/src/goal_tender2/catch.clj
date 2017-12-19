(ns goal-tender2.catch
  "For jotting down ideas in the middle of the day

The slash/hack version tempts me to use a reference to datomic.api
here.

Honestly, avoiding that was the main reason I wrote substratum."
  (:require [datomic.api :as d]
            [clojure.spec.alpha :as s]))

(defn add-dream
  "For jotting down a basic ideas

The top trouble with just using a URL like this
is that doing `with` exploration isn't transparent,
the way it should be.

Problem 2: I'm already storing the connection in dev/user.clj,
instead of the arbitrary url

So I'm covering my bases twice"
  [url summary]
  (let [cxn (d/connect url)
        txn {:todo/summary summary
             :todo/state :todo.state/dreaming}]
    @(d/transact cxn [txn])))

;;; TODO: These next pieces really don't belong in here

(defn list-dreams
  [url]
  ;; Q: What's the :todo/done clause doing here?
  ;; (I *know* it's part of the PULL syntax. I just
  ;; don't remember what it means
  (let [sql '[:find (pull ?e [:db/id :todo/summary :todo/done])
              :where
              [?e :todo/state :todo.state/dreaming]]
        db (-> url d/connect d/db)]
    (d/q sql db)))

(s/fdef choose-dreams-fate
        :args (s/cat :cxn any? ; Q: HOWTO spec this?
                     :dream-id integer?
                     :fate #{:todo.state/dreaming
                             :todo.state/todo
                             :todo.state/dumped
                             :todo.state/deferred
                             :todo.state/done})
        ;; This really should return a transaction
        ;; outcome.
        ;; I'm fairly sure this is another reason to
        ;; use substratum
        :ret any?)
(defn choose-dreams-fate
  "Do, Dump, or Deliberate"
  [cxn dream-id fate]
  (let [alteration [{:db/ident dream-id
                     :todo/state fate}]]
    (d/transact cxn alteration)))