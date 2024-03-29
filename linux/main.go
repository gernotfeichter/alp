//go:generate go run github.com/ogen-go/ogen/cmd/ogen@v0.73.0 --target api -package api --clean openapi.yaml --convenient-errors on

/*
Copyright © 2023 Gernot Feichter

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
package main

import "github.com/gernotfeichter/alp/cmd"

func main() {
	cmd.Execute()
}
