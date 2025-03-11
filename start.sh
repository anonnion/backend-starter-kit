#!/bin/bash
# # 1. Create a new Laravel project
# composer create-project --prefer-dist laravel/laravel .

# # 2. Move into the project directory
# cd cms  

# # 3. Set up environment file
# cp .env.example .env  

# # 4. Install dependencies
# composer install  

# # 5. Generate application key
# php artisan key:generate  

# # 6. Set up database (update .env with DB credentials first)
# php artisan migrate  

# # 7. Install Laravel Breeze for authentication (choose a stack)
# composer require laravel/breeze --dev  
# php artisan breeze:install api  
# php artisan migrate  

# # 8. Install Laravel Sanctum for API authentication
# composer require laravel/sanctum  
# php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"  
# php artisan migrate  

# # 9. Set up storage link (if needed)
# php artisan storage:link  

# # 10. Start the development server
# php artisan serve  

# composer require --dev pestphp/pest pestphp/pest-plugin-laravel
# npm install -D @playwright/test
# npx playwright install
# npx playwright install-deps

set -e

# Define color variables
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Creating a new Laravel project 🚀 ===${NC}"
composer create-project --prefer-dist laravel/laravel cms

composer require spatie/laravel-data

php artisan vendor:publish --provider="Spatie\LaravelData\LaravelDataServiceProvider" --tag="data-config"

cd cms

echo -e "${YELLOW}=== Setting up environment 🛠 ===${NC}"
cp .env.example .env

echo -e "${GREEN}=== Installing Composer dependencies 📦 ===${NC}"
composer install

echo -e "${BLUE}=== Generating Application Key 🔑 ===${NC}"
php artisan key:generate

echo -e "${GREEN}=== Running initial migrations 🗃 ===${NC}"
php artisan migrate

echo -e "${YELLOW}=== Installing Laravel Breeze (API stack) 🌬 ===${NC}"
composer require laravel/breeze --dev
php artisan breeze:install api
npm install && npm run dev
php artisan migrate

echo -e "${BLUE}=== Installing Laravel Sanctum 🛡 ===${NC}"
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\\Sanctum\\SanctumServiceProvider"
php artisan migrate

echo -e "${GREEN}=== Creating storage symlink (if needed) 🔗 ===${NC}"
php artisan storage:link

echo -e "${YELLOW}=== Installing Pest for testing 🧪 ===${NC}"
composer require --dev pestphp/pest pestphp/pest-plugin-laravel

echo -e "${BLUE}=== Installing Playwright for E2E testing 🎭 ===${NC}"
npm install -D @playwright/test
npx playwright install
npx playwright install-deps

echo -e "${GREEN}=== Installing ESLint, Prettier, Husky, and lint-staged 🎨 ===${NC}"
npm install --save-dev eslint eslint-config-prettier eslint-plugin-prettier prettier husky lint-staged

echo -e "${YELLOW}=== Creating ESLint configuration (.eslintrc.json) 📝 ===${NC}"
cat > .eslintrc.json << 'EOF'
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": ["eslint:recommended", "plugin:prettier/recommended"],
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "rules": {
    "prettier/prettier": "error",
    "no-console": "warn",
    "no-unused-vars": "warn"
  }
}
EOF

echo -e "${BLUE}=== Updating package.json scripts and lint-staged configuration 📑 ===${NC}"
# NOTE: Please update your package.json manually to include the following snippets:
cat << 'EOF'

Add the following to your "scripts" section:
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:debug": "playwright test --ui",
    "test:e2e:report": "playwright test --reporter=html",
    "lint": "eslint . --ext .js,.ts",
    "format": "prettier --write ."
  }
}

And add the following "lint-staged" configuration:
{
  "lint-staged": {
    "**/*.{js,ts}": [
      "eslint --fix",
      "prettier --write"
    ]
  }
}

Then run:
npm install
EOF

echo -e "${GREEN}=== Setting up Husky pre-commit hook 🐶 ===${NC}"
npx husky install
npx husky add .husky/pre-commit "npx lint-staged"

echo -e "${BLUE}=== Initial Laravel CMS project setup complete! 🎉 ===${NC}"
