export const x = "";
const input = await Deno.readTextFile("./input.txt");

type Range = {
  dstStart: number;
  srcStart: number;
  rangeLength: number;
};

type AlmanacMap = {
  dstType: string;
  ranges: Range[];
};

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

const seedMap = new Map<number, Map<number, number>>();

seeds.forEach((seed) => {
  let map: AlmanacMap | undefined = maps.get("seed");
  let currentTransform = seed;
  while (map !== undefined) {
    // console.log({ map });

    let transform = currentTransform;
    map.ranges.forEach((range) => {
      // console.log({ range });
      // console.log({ currentTransform });
      if (
        currentTransform >= range.srcStart &&
        currentTransform < range.srcStart + range.rangeLength
      ) {
        transform = range.dstStart + (currentTransform - range.srcStart);
        // console.log({ transform });
      }
    });

    if (!seedMap.has(seed)) {
      const transforms = new Map<number, number>();
      transforms.set(currentTransform, transform);
      seedMap.set(seed, transforms);
    } else {
      // console.log({ seed, currentTransform, transform });
      seedMap.get(seed)!.set(currentTransform, transform);
    }
    map = maps.get(map.dstType);
    currentTransform = seedMap.get(seed)!.get(currentTransform)!;
  }
});

// console.log({ seeds, maps });
// console.log({ seedMap });

const output = Math.min(...seeds.map((seed) => {
  let prev = -1;
  let transform = seedMap.get(seed)!.get(seed);
  while (transform && transform !== prev) {
    prev = transform;
    transform = seedMap.get(seed)!.get(transform);
  }
  return prev;
}));

console.log("answer", output);
