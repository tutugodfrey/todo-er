sed -i -e 's/JWTSECRET/'$JWT_SECRET/ .env
sed -i -e 's/APPPORT/'$PORT/ .env
sed -i -e 's/IP/'$IP/ .env
