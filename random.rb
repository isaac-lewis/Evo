class Random
  def self.between(start,fin)
    start + rand(fin - start + 1)
  end

  def self.split_up(amt, num_buckets)
    buckets = [0] * num_buckets
    amt.times do
      buckets[rand(num_buckets)] += 1
    end

    buckets
  end
end
