


// Create a library 'cargo new --lib d2_iterators'

pub struct RangeIterator {
    curr: i32,
    stop: i32,
    step: i32,
}

impl RangeIterator {
    pub fn new(start: i32, stop: i32, step: i32) -> Self {
        RangeIterator {
            curr: start,
            stop,
            step,
        }
    }
}

impl Iterator for RangeIterator {
    type Item = i32;
    // next should have a mutable ref to self as it can modify the object
    fn next(&mut self) -> Option<Self::Item> {
        if self.curr >= self.stop {
            return None;
        }
        let res = self.curr;
        self.curr += self.step;
        Some(res)
    }
}

// Test area - cfg(test) will not be oart of final binary
// 
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test1() {
        let mut m = 0;
        let it = RangeIterator::new(5, 12, 3);
        for s in it {
            m += s;
        }
        assert_eq!(m, 5 + 8 + 11, "Test 1");
    }
    #[test]
    fn test2() {
        let mut m = 0;
        let it = RangeIterator::new(5, 12, 3);
        for s in it {
            m += s;
        }
        assert_eq!(m, 5 + 8 + 12, "Test 2");
    }
}

