package main

import "fmt"

func main() {
    fmt.Print("Enter a number in meters: ")
    var input float64
    fmt.Scanf("%f", &input)

    output := input / 0.3048

    fmt.Println("Translate in foots: ", output)
}
