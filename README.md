
![1](https://github.com/user-attachments/assets/db19a406-cedb-4b63-92bf-c61e3824ca43)

<img width="1196" height="876" alt="Screenshot 2026-01-04 at 03 25 48" src="https://github.com/user-attachments/assets/a0dc7cf8-2d90-4990-922b-f3134166e253" />
<img width="1196" height="876" alt="Screenshot 2026-01-04 at 03 25 55" src="https://github.com/user-attachments/assets/a5d103cb-79fc-460b-a740-4f436caef1c6" />


📱 UIKit Social Media App (MVP)

A production-style social media app built with UIKit, designed to deeply master UIKit architecture, MVVM-Coordinator, and real-world app patterns.

This project started from a simple question:

Do I really understand UIKit — or am I just getting by?

So I stopped guessing and built a real app.

Somewhere along the way, the doubt disappeared.
Now I’m fully confident in my UIKit skills — and I kinda fell in love with UIKit again.

⸻

✨ Overview

This is an Instagram-like social media app built entirely with UIKit, powered by Supabase as a backend, and structured using MVVM + Coordinator architecture.

It focuses on:
	•	clean navigation
	•	scalable state management
	•	realtime data handling
	•	pagination
	•	optimistic UI
	•	long-term maintainability

This is an MVP, but built on a very strong foundation so future features can be added easily without refactoring everything.

⸻

🚀 Features

🔐 Authentication & Onboarding
	•	Email/password sign up & login
	•	Email confirmation flow
	•	Forgot password via email deep link
	•	Apple Sign In
	•	Google Sign In
	•	Secure logout
	•	First-time onboarding
	•	Profile creation (avatar, username, bio)

⸻

🧭 App Structure
	•	Three main tabs:
	•	Feed
	•	Search
	•	Profile
	•	Navigation handled with MVVM-Coordinator
	•	No direct VC-to-VC navigation
	•	Predictable, testable flows

⸻

📰 Feed
	•	Global feed (visible posts only)
	•	Cursor-based pagination
	•	Pull-to-refresh
	•	Realtime updates (insert / update / delete)
	•	New posts are buffered while scrolling
	•	“Show new posts” action
	•	Stable ordering & deduplication

⸻

❤️ Post Interactions
	•	Like / unlike posts (optimistic UI)
	•	Save / unsave posts
	•	Comment on posts
	•	Delete own posts and comments
	•	“More” action sheet for post actions

⸻

🌍 Translation
	•	Translate post captions and comments
	•	Toggle between original and translated text
	•	Powered by DeepL API

⸻

👤 Profiles
	•	View own and other users’ profiles
	•	Follow / unfollow users
	•	Remove followers
	•	Followers & following counts
	•	Profile tabs:
	•	Posts
	•	Liked posts
	•	Saved posts
	•	Edit profile (avatar, username, bio)
	•	Share profile via deep link

⸻

🔍 Search
	•	Search users by username
	•	Navigate directly to profiles

⸻

🧠 Architecture & Technical Highlights

Architecture
	•	UIKit
	•	MVVM-Coordinator
	•	Service-layer driven design
	•	Protocol-oriented programming
	•	SOLID principles

State & Concurrency
	•	Combine for reactive UI binding
	•	Swift Concurrency (async/await) end-to-end
	•	@MainActor-safe UI updates
	•	Task cancellation & lifecycle control

Backend
	•	Supabase
	•	Auth
	•	Storage (avatars & post images)
	•	Realtime v2 subscriptions
	•	PostgreSQL
	•	RPC functions for:
	•	Global feed
	•	User feed
	•	Profile data
	•	Search
	•	Post actions

Realtime
	•	Insert / update / delete subscriptions
	•	Buffered realtime posts
	•	Typed decoding for Postgres payloads
	•	Clean subscribe / unsubscribe lifecycle

Data Handling
	•	Cursor-based pagination
	•	Optimistic updates with rollback
	•	Author caching with TTL
	•	Image caching (Kingfisher)
	•	Safe deduplication logic

Deep Linking
	•	myapp://auth-callback
	•	myapp://account/update-password
	•	myapp://u/<uuid> → profile

⸻

🧩 Dependencies
	•	Supabase
	•	Combine
	•	Kingfisher
	•	GoogleSignIn
	•	AppAuth
	•	KeychainAccess
	•	TOCropViewController
	•	Swift Concurrency Extras
	•	DeepL API

⸻

🛠️ Why This Project Exists

This app was built to prove UIKit mastery, not to chase features.

It taught me more than tutorials ever could:
	•	how real apps scale
	•	how architecture saves time later
	•	how to design for change
	•	how to combine UIKit, SwiftUI, Combine, and async/await cleanly

This is just the beginning — with this foundation, adding future features will be easy, safe, and fun.

