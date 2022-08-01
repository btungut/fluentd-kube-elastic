def start
    super
    puts "---FLUENTD KUBE ELASTIC---"
    puts "Please visit : https://github.com/btungut/fluentd-kube-elastic"
  end

def filter(tag, time, record)
    if !record.nil? && !record["kubernetes"].nil?
        replaceDotsWithUnderscore(record["kubernetes"])
    end
    record
end


def replaceDotsWithUnderscore(myHash)
    newHash = Hash.new
    myHash.each do |key, value|
        if key.include?(".")
            newkey = key.dup.gsub! '.', '_'
            newHash[newkey] = myHash[key]
        else
            newHash[key] = myHash[key]
        end

        if value.is_a?(Hash)
            replaceDotsWithUnderscore(value)
        end
    end
    myHash.replace(newHash)
end
  