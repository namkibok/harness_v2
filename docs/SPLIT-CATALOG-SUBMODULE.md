# 카탈로그를 별도 repo + submodule로 분리 (선택)

현재 `skills/catalog/`는 **harness_v2에 포함**되어 있어 `git clone` 한 번으로 팀 공유가 됩니다.  
카탈로그만 따로 버전 관리하려면 아래 순서로 `namkibok/cursor-skills`를 만듭니다.

## 1. GitHub에 빈 repo 생성

- 이름: `cursor-skills`
- Public (또는 팀 Private)

## 2. 로컬 카탈로그 push (이미 커밋된 경우)

```powershell
cd E:\workspace\skills\cursor
git remote add origin https://github.com/namkibok/cursor-skills.git
git push -u origin main
```

## 3. harness_v2에서 vendored catalog 제거 후 submodule

```powershell
cd harness_v2
git rm -r skills/catalog
git commit -m "chore: remove vendored catalog before submodule"
git submodule add https://github.com/namkibok/cursor-skills.git skills/catalog
git commit -m "chore: add cursor-skills submodule"
git push
```

## 4. 팀원 clone

```powershell
git clone --recurse-submodules https://github.com/namkibok/harness_v2.git
```

`HARNESS_SKILL_CATALOG` 기본값은 `{harness_v2_root}/skills/catalog` 로 유지됩니다.
