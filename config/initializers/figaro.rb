# throw error if the keys below is not set in application.yml 
Figaro.require_keys("SECRET_KEY_BASE", "UPUSHIE_DATABASE_USERNAME", "UPUSHIE_DATABASE_PASSWORD", "UPUSHIE_API_KEY", "API_VERSION")