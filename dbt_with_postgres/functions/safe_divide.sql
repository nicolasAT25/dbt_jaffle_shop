select
    case
        when denominator::int = 0 then null
        else numerator::int / denominator
    end