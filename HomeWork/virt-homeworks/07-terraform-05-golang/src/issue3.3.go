package main

import "fmt"

func main() {
    fmt.Print("All numbers divided by [3]: ")
    j := 0
    for i := 0; i<100; i++ {
        j +=i
        if (i % 3 == 0) && (i != 0) {
        fmt.Print(i,", ")
        }
    }
    fmt.Println()
    fmt.Println("This is the end")
}
