export const x = "";
const input = await Deno.readTextFile("./input.txt");

type TransformRange = {
  dstStart: number;
  srcStart: number;
  rangeLength: number;
};

type AlmanacMap = {
  dstType: string;
  ranges: TransformRange[];
};

type Range = { start: number; end: number };

const blocks = input.split("\n\n");

const seeds: number[] = blocks[0].substring(blocks[0].indexOf(": ") + 2).split(
  " ",
).map((s) => parseInt(s, 10));
const maps: Map<string, AlmanacMap> = new Map();

blocks.slice(1).forEach((block) => {
  const [mapping, ...ranges] = block.split("\n");
  const [srcType, _, dstType] = mapping.substring(0, mapping.indexOf(" "))
    .split("-");

  maps.set(srcType, {
    dstType,
    ranges: ranges.filter((x) => x).map((range) => {
      const [dstStart, srcStart, rangeLength] = range.split(" ").map((s) =>
        parseInt(s, 10)
      );
      return { dstStart, srcStart, rangeLength };
    }),
  });
});

const seedRanges: Range[] = seeds.reduce(
  (acc: Range[], current, index) => {
    if (index % 2 === 0) {
      acc.push({ start: current, end: seeds[index] + seeds[index + 1] - 1 });
    }
    return acc;
  },
  [],
);

function isBetween(range: Range, value: number) {
  return value >= range.start && value < range.end;
}

function applyTransform(range: TransformRange, value: number) {
  return range.dstStart + (value - range.srcStart);
}

let lowest = Infinity;

function dfs(seedRange: Range, map: AlmanacMap, path: Range[]) {
  const transforms: Range[] = [];

  map.ranges.forEach((range) => {
    const srcRange = {
      start: range.srcStart,
      end: range.srcStart + range.rangeLength - 1,
    };

    // case 1: you fall completely within the range
    if (
      isBetween(srcRange, seedRange.start) &&
      isBetween(srcRange, seedRange.end)
    ) {
      transforms.push({
        start: applyTransform(range, seedRange.start),
        end: applyTransform(range, seedRange.end),
      });
    }

    // case 2: you fall partially within the range
    if (
      !isBetween(srcRange, seedRange.start) &&
      isBetween(srcRange, seedRange.end)
    ) {
      transforms.push(...[{
        start: seedRange.start,
        end: srcRange.start - 1,
      }, {
        start: applyTransform(range, srcRange.start),
        end: applyTransform(range, seedRange.end),
      }]);
    } else if (
      isBetween(srcRange, seedRange.start) &&
      !isBetween(srcRange, seedRange.end)
    ) {
      transforms.push(...[{
        start: applyTransform(range, seedRange.start),
        end: applyTransform(range, srcRange.end),
      }, {
        start: srcRange.end + 1,
        end: seedRange.end,
      }]);
    }

    if (
      !isBetween(srcRange, seedRange.start) &&
      !isBetween(srcRange, seedRange.end)
    ) {
      // case 3: you completely encompass the range on either side
      if (seedRange.start < srcRange.start && seedRange.end > srcRange.end) {
        transforms.push(...[{
          start: seedRange.start,
          end: srcRange.start - 1,
        }, {
          start: applyTransform(range, srcRange.start),
          end: applyTransform(range, srcRange.end),
        }, {
          start: srcRange.end + 1,
          end: seedRange.end,
        }]);
      }
    }
  });

  // case 4: you fall completely outside the range
  if (transforms.length === 0) {
    transforms.push({
      start: seedRange.start,
      end: seedRange.end,
    });
  }

  // we hit a leaf node
  if (map.dstType === "location") {
    lowest = Math.min(
      lowest,
      ...transforms.map((t) => t.start).filter((x) => x > 0),
    );
  } else {
    transforms.forEach((transform) => {
      path.push(transform);
      dfs(transform, maps.get(map.dstType)!, path);
      path.pop();
    });
  }
}

seedRanges.forEach((seedRange) => {
  dfs(seedRange, maps.get("seed")!, [seedRange]);
});

const output = lowest;
console.log("answer", output);
