export const x = "";
const input = await Deno.readTextFile("./input.txt");

const rowToString = (
  matrix: string[][],
  y: number,
  start: number,
  stop: number,
) => {
  const delta = start < stop ? 1 : -1;

  let string = "";

  for (let x = start; x !== stop; x += delta) {
    string += matrix[y][x];
  }

  return string;
};

const colToString = (
  matrix: string[][],
  x: number,
  start: number,
  stop: number,
) => {
  const delta = start < stop ? 1 : -1;

  let string = "";

  for (let y = start; y !== stop; y += delta) {
    string += matrix[y][x];
  }

  return string;
};

function countReflectedCols(matrix: string[][]) {
  for (let x = 1; x < matrix[0].length; x++) {
    let didBreak = false;

    for (let y = 0; y < matrix.length; y++) {
      if (x <= matrix[0].length / 2) {
        if (
          rowToString(matrix, y, 0, x) !==
            rowToString(matrix, y, x + x - 1, x - 1)
        ) {
          didBreak = true;
          break;
        }
      } else {
        if (
          rowToString(matrix, y, x - (matrix[0].length - x), x) !==
            rowToString(matrix, y, matrix[0].length - 1, x - 1)
        ) {
          didBreak = true;
          break;
        }
      }
    }

    if (!didBreak) {
      return x;
    }
  }

  return undefined;
}

const countReflectedRows = (matrix: string[][]) => {
  for (let y = 1; y < matrix.length; y += 1) {
    let didBreak = false;

    for (let x = 0; x < matrix[y].length; x += 1) {
      if (y <= matrix.length / 2) {
        if (
          colToString(matrix, x, 0, y) !==
            colToString(matrix, x, y + y - 1, y - 1)
        ) {
          didBreak = true;
          break;
        }
      } else {
        if (
          colToString(matrix, x, y - (matrix.length - y), y) !==
            colToString(matrix, x, matrix.length - 1, y - 1)
        ) {
          didBreak = true;
          break;
        }
      }
    }

    if (!didBreak) {
      return y;
    }
  }

  return undefined;
};

const patterns = input.split("\n\n").map((p) =>
  p.split("\n").filter((x) => x).map((l) => l.split(""))
);

const scores = patterns.map((p) => {
  const cols = countReflectedCols(p);
  if (cols) {
    return cols;
  }

  const rows = countReflectedRows(p);
  if (rows) {
    return 100 * rows;
  }

  return 0;
});

const sum = scores.reduce((a, b) => a + b, 0);
console.log("answer", sum);
