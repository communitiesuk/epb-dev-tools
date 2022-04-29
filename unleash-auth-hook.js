const auth = require('basic-auth')
const userName = process.env.TOGGLES_USERNAME
const password = process.env.TOGGLES_PASSWORD

function basicAuthentication (app, config, services) {
  const { baseUriPath } = config.server
  const { accessService, userService } = services
  const requiredPermission = 'CREATE_API_TOKEN'

  async function fetchEditorRole () {
    const roles = await accessService.getRootRoles()
    return roles.find(r => r.name === 'Editor')
  }

  async function ensureEditorRoleCanCreateApiToken () {
    const editorRole = await fetchEditorRole()
    const { permissions: editorPermissions } = await accessService.getRole(editorRole.id)
    if (editorPermissions.some(userPermission => userPermission.permission === requiredPermission)) return
    await accessService.addPermissionToRole(editorRole.id, requiredPermission)
  }

  app.use(`${baseUriPath}/api/admin/user`, async (req, res, next) => {
    if (req.user) {
      return next()
    }
    if (req.session.user) {
      req.user = req.session.user
      return next()
    }

    return res
      .status('401')
      .set({ 'WWW-Authenticate': 'Basic realm="example"' })
      .end('access denied')
  })

  app.use(`${baseUriPath}/`, async (req, res, next) => {
    if ([
      'client/metrics',
      'client/features',
      'client/register'
    ].some(path => req.path.startsWith(`${baseUriPath}/api/${path}`))) {
      return next()
    }

    const credentials = auth(req)

    if (credentials) {
      if (credentials.name === userName && credentials.pass === password) {
        const email = `${credentials.name}@domain.com`
        // ensure EDITOR role has CREATE_API_TOKEN permission
        await ensureEditorRoleCanCreateApiToken()
        const user = await userService.loginUserWithoutPassword(email, true)
        req.user = user
        req.session.user = user
        return next()
      }
    } else {
      return res
        .status('401')
        .set({ 'WWW-Authenticate': 'Basic realm="example"' })
        .end('access denied')
    }
  })

  app.use((req, res, next) => {
    // Updates active sessions every hour
    req.session.nowInHours = Math.floor(Date.now() / 3600e3)
    next()
  })
}

module.exports = basicAuthentication
