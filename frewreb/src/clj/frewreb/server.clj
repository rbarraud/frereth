(ns frewreb.server
  (:use org.httpkit.server))

;;; To run the jetty server. The server symbol is not private to
;;; allows to start and stop thejetty server from the repl.
#_(defn run
  "Run the ring server. It defines the server symbol with defonce."
  []
  (defonce server
    (jetty/run-jetty #'site {:port 3000 :join? false}))
  server)

(defn start-web
  "Returns the stop function"
  ([app]
     (start-web 8090 app))
  ([port app]
     (start-web port app "127.0.0.1" 4))
  ([port app address threads]
     (run-server app {:port 8080
                      :ip address
                      :thread threads})))
