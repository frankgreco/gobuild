package main

import (
    "io"
    "fmt"
    "log"
    "net/http"

    "github.com/opentracing/opentracing-go"
)

type Resp struct {
    Message string `json:"message"`
}

func handler(w http.ResponseWriter, r *http.Request) {
    opName := fmt.Sprintf("%s %s", r.Method, r.URL.Path)
    var sp opentracing.Span
	spCtx, err := opentracing.GlobalTracer().Extract(opentracing.TextMap,
		opentracing.HTTPHeadersCarrier(r.Header))
	if err == nil {
		sp = opentracing.StartSpan(opName, opentracing.ChildOf(spCtx))
	} else {
		sp = opentracing.StartSpan(opName)
	}
	defer sp.Finish()

    response, err := http.Get("https://www.google.com")
    if err != nil {
        log.Fatal(err)
    } else {
        defer response.Body.Close()
        _, err := io.Copy(w, response.Body)
        if err != nil {
            log.Fatal(err)
        }
    }
}

func main() {
    http.HandleFunc("/foo", handler)
    http.ListenAndServe(":8080", nil)
}