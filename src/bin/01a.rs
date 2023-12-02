use anyhow::Result;

fn main() -> Result<()> {
    let calibration: u32= include_str!("./01.input")
        .lines()
        .map(|s| s.chars().filter_map(|c| c.to_digit(10)).collect())
        .map(|v: Vec<u32>| {
            (v.first().unwrap_or(&0).to_string() + v.last().unwrap_or(&0).to_string().as_str())
                .parse::<u32>()
                .unwrap()
        }).sum();

    println!("{calibration}");
    return Ok(());
}
