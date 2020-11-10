export const jsonHeaders = {
  "Content-Type": "application/json"
}

export const acceptJson = {
  "Accept": "application/json"
}

export function withAuth(oauthToken: string) {
  return {
    "Authorization": `token ${oauthToken}`
  }
}
