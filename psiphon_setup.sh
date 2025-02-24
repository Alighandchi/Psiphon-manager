#!/bin/bash

# لیست لوکیشن‌ها
locations=("AT" "AU" "BE" "BG" "BR" "CA" "CH" "CZ" "DE" "DK" "EE" "ES" "FI" "FR" "GB" "GR" "HR" "HU" "ID" "IE" "IN" "IT" "JP" "LV" "LT" "NL" "NO" "PL" "PT" "RO" "RS" "SE" "SG" "SK" "UA" "US")

# مسیر روت برای سرورها
base_dir="/root/Psiphon-Server"
mkdir -p "$base_dir"

# دانلود فایل باینری مورد نیاز
binary_url="https://raw.githubusercontent.com/Psiphon-Labs/psiphon-tunnel-core-binaries/master/linux/psiphon-tunnel-core-x86_64"

# مقدار پورت اولیه
port=9001

for loc in "${locations[@]}"; do
    folder="$base_dir/${loc}-${port}"
    mkdir -p "$folder"
    
    # دانلود فایل باینری و تغییر نام آن
    wget -q "$binary_url" -O "$folder/psiphon-tunnel-core-x86_64-${loc}"
    chmod +x "$folder/psiphon-tunnel-core-x86_64-${loc}"
    
    # ایجاد فایل پیکربندی
    cat > "$folder/psiphon.config" <<EOL
{
    "LocalSocksProxyPort": $port,
    "EgressRegion": "$loc",
    "PropagationChannelId": "FFFFFFFFFFFFFFFF",
    "RemoteServerListDownloadFilename": "remote_server_list",
    "RemoteServerListSignaturePublicKey": "MIICIDANBgkqhkiG9w0BAQEFAAOCAg0AMIICCAKCAgEAt7Ls+/39r+T6zNW7GiVpJfzq/xvL9SBH5rIFnk0RXYEYavax3WS6HOD35eTAqn8AniOwiH+DOkvgSKF2caqk/y1dfq47Pdymtwzp9ikpB1C5OfAysXzBiwVJlCdajBKvBZDerV1cMvRzCKvKwRmvDmHgphQQ7WfXIGbRbmmk6opMBh3roE42KcotLFtqp0RRwLtcBRNtCdsrVsjiI1Lqz/lH+T61sGjSjQ3CHMuZYSQJZo/KrvzgQXpkaCTdbObxHqb6/+i1qaVOfEsvjoiyzTxJADvSytVtcTjijhPEV6XskJVHE1Zgl+7rATr/pDQkw6DPCNBS1+Y6fy7GstZALQXwEDN/qhQI9kWkHijT8ns+i1vGg00Mk/6J75arLhqcodWsdeG/M/moWgqQAnlZAGVtJI1OgeF5fsPpXu4kctOfuZlGjVZXQNW34aOzm8r8S0eVZitPlbhcPiR4gT/aSMz/wd8lZlzZYsje/Jr8u/YtlwjjreZrGRmG8KMOzukV3lLmMppXFMvl4bxv6YFEmIuTsOhbLTwFgh7KYNjodLj/LsqRVfwz31PgWQFTEPICV7GCvgVlPRxnofqKSjgTWI4mxDhBpVcATvaoBl1L/6WLbFvBsoAUBItWwctO2xalKxF5szhGm8lccoc5MZr8kfE0uxMgsxz4er68iCID+rsCAQM=",
    "RemoteServerListUrl": "https://s3.amazonaws.com//psiphon/web/mjr4-p23r-puwl/server_list_compressed",
    "SponsorId": "FFFFFFFFFFFFFFFF",
    "UseIndistinguishableTLS": true
}
EOL
    
    ((port++))
done

echo "تمام سرورهای سایفون ساخته شدند!"
