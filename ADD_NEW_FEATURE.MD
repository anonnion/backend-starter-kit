# Developer Workflow Guide

This guide explains the process that every developer is expected to follow when contributing to the CMS repository. It covers steps from pulling the code, developing a new feature (we’ll use the "Add Comment" feature as an example), testing, and submitting a PR. Follow these steps to ensure consistency, maintain quality, and pass our CI/CD pipeline checks.

---

## 1. **Pulling the Latest Code**

1. **Clone the Repository (if not already cloned):**

   ```bash
   git clone git@github.com:your-org/laravel-cms.git
   cd laravel-cms
   ```

2. **Fetch the Latest Changes:**

   ```bash
   git checkout main
   git pull origin main
   ```

3. **Create a New Branch for Your Feature:**

   - Use a consistent branch naming convention (e.g., `feature/add-comment`):
     
     ```bash
     git checkout -b feature/add-comment
     ```

---

## 2. **Developing the "Add Comment" Feature**

### **a. Create Migration & Model**

1. **Generate a Comment Model with Migration:**

   ```bash
   php artisan make:model Comment -m
   ```

2. **Edit the Migration File** (`database/migrations/xxxx_xx_xx_create_comments_table.php`):

   ```php
   <?php

   use Illuminate\Database\Migrations\Migration;
   use Illuminate\Database\Schema\Blueprint;
   use Illuminate\Support\Facades\Schema;

   class CreateCommentsTable extends Migration
   {
       public function up()
       {
           Schema::create('comments', function (Blueprint $table) {
               $table->id();
               $table->foreignId('post_id')->constrained()->onDelete('cascade');
               $table->foreignId('user_id')->constrained()->onDelete('cascade');
               $table->text('content');
               $table->timestamps();
           });
       }

       public function down()
       {
           Schema::dropIfExists('comments');
       }
   }
   ```

3. **Run the Migration:**

   ```bash
   php artisan migrate
   ```

4. **Update the Comment Model** (`app/Models/Comment.php`):

   ```php
   <?php

   namespace App\Models;

   use Illuminate\Database\Eloquent\Factories\HasFactory;
   use Illuminate\Database\Eloquent\Model;

   class Comment extends Model
   {
       use HasFactory;

       protected $fillable = ['post_id', 'user_id', 'content'];

       public function post()
       {
           return $this->belongsTo(Post::class);
       }

       public function user()
       {
           return $this->belongsTo(User::class);
       }
   }
   ```

5. **Update the Post Model** (`app/Models/Post.php`) to include:

   ```php
   public function comments()
   {
       return $this->hasMany(Comment::class);
   }
   ```

---

### **b. Create Controller & API Route**

1. **Generate the Controller:**

   ```bash
   php artisan make:controller CommentController --api
   ```

2. **Implement the Store Method** in `app/Http/Controllers/CommentController.php`:

   ```php
   <?php

   namespace App\Http\Controllers;

   use App\Models\Post;
   use Illuminate\Http\Request;

   class CommentController extends Controller
   {
       public function store(Request $request, Post $post)
       {
           $validated = $request->validate([
               'content' => 'required|string',
           ]);

           $comment = $post->comments()->create([
               'user_id' => auth()->id(),
               'content' => $validated['content'],
           ]);

           return response()->json($comment, 201);
       }
   }
   ```

3. **Add API Route** in `routes/api.php`:

   ```php
   Route::middleware('auth:sanctum')->group(function () {
       Route::post('/posts/{post}/comments', [CommentController::class, 'store']);
   });
   ```

---

## 3. **Testing the Feature**

### **a. Unit & Feature Tests**

1. **Create a Test File:**

   ```bash
   php artisan make:test CommentTest
   ```

2. **Write Tests in `tests/Feature/CommentTest.php`:**

   ```php
   <?php

   namespace Tests\Feature;

   use App\Models\Comment;
   use App\Models\Post;
   use App\Models\User;
   use Illuminate\Foundation\Testing\RefreshDatabase;
   use Tests\TestCase;

   class CommentTest extends TestCase
   {
       use RefreshDatabase;

       public function test_user_can_add_comment()
       {
           $user = User::factory()->create();
           $post = Post::factory()->create();

           $response = $this->actingAs($user, 'sanctum')->postJson("/api/posts/{$post->id}/comments", [
               'content' => 'This is a comment'
           ]);

           $response->assertStatus(201);
           $this->assertDatabaseHas('comments', ['content' => 'This is a comment']);
       }
   }
   ```

3. **Run Tests Locally:**

   ```bash
   php artisan test
   ```

### **b. End-to-End (E2E) Tests**

1. **Create an E2E Test File:** (e.g., `tests/e2e/comments.spec.ts`)

   ```typescript
   import { test, expect } from '@playwright/test';

   test('User can add a comment', async ({ page }) => {
     // Navigate to a post page (ensure this page exists and is accessible in testing)
     await page.goto('/post/1');
     // Fill in the comment input field and submit the form
     await page.fill('#comment-input', 'This is a comment');
     await page.click('#submit-comment');
     // Verify the comment is displayed
     await expect(page.locator('.comment-item')).toHaveText('This is a comment');
   });
   ```

2. **Run E2E Tests Locally:**

   Start the Laravel development server:
   ```bash
   php artisan serve
   ```

   Then run:
   ```bash
   npx playwright test
   ```

---

## 4. **Pre-commit & Linting Checks**

1. **Ensure All Changes Pass Linting:**

   ```bash
   npm run lint
   ```

2. **Stage Your Changes:**

   ```bash
   git add .
   ```

3. **Commit Using the Correct Format:**

   ```bash
   git commit -m "feat(comment): add comment feature with API endpoint and tests"
   ```

   *Husky and lint-staged will automatically run ESLint and Prettier on your staged files before the commit completes.*

---

## 5. **Creating a Pull Request (PR)**

1. **Push Your Branch to GitHub:**

   ```bash
   git push origin feature/add-comment
   ```

2. **Open a Pull Request:**
   - Navigate to your GitHub repository.
   - Click **"Compare & pull request"** for your branch.
   - Use the PR template provided by your team.
   - Ensure you detail:
     - The changes made (migration, model, controller, routes, tests).
     - Any relevant links to issues or task boards.
     - Confirmation that all linting and tests have passed.

3. **CI/CD Pipeline Execution on PR:**
   - On PR creation, our GitHub Actions workflows (`lint.yml`, `unit_test.yml`, `e2e.yml`) run automatically.
   - Ensure all checks pass before requesting a review.

4. **Review & Approval:**
   - Once reviewers approve the PR and all tests pass, merge into the `main` branch.
   - After merge, the deployment workflow (triggered on `push` to main) will run tests again and deploy the changes to Digital Ocean VPS.

---

## 6. **Post-merge Deployment**

After the PR is approved and merged:
- The **CI/CD pipeline** runs the deployment workflow.
- It pulls the latest code on the Digital Ocean VPS, runs migrations, clears caches, and restarts services.
- You can verify the new comment feature on the production site.

---

## Summary

1. **Pull the latest code.**
2. **Create a new feature branch (e.g., `feature/add-comment`).**
3. **Develop the feature:**  
   - Create migration & model.  
   - Update controllers & routes.  
   - Write unit and E2E tests.
4. **Run all tests and lint checks locally.**
5. **Commit changes (with pre-commit hooks ensuring code quality).**
6. **Push branch and create a PR with the required documentation.**
7. **Wait for CI tests to pass and reviewers to approve.**
8. **Merge into main and deploy via CI/CD pipeline.**

