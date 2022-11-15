# ハッカー飯予約アプリ

ハッカー飯の Flutter × Supabase ハンズオンの中で作った予約アプリです！

- 背景の白い空いている予約枠タップで予約！
- 予約済みの枠は赤色表示
- 予約済みの枠を予約しようとすると警告文表示

## テーブル定義

```sql
create table reservations (
  id uuid default uuid_generate_v4() not null primary key,
  time_slot tstzrange not null,
  user_id uuid default auth.uid() not null references auth.users(id),
  title text not null,
  exclude using gist (time_slot WITH &&)
);
```
