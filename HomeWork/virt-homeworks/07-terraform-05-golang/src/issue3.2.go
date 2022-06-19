package main

import "fmt"

func main() {
    var x = []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17}
    fmt.Println ("All Numbers : ", x)
    var min int = x[0]
    for _, y := range x {
	if y < min {
	    min = y
	}
    }
    fmt.Println("Minimal number :", min)
}
