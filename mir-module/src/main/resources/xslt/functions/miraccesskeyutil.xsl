<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:miraccesskeyutil="http://www.mycore.de/xslt/miraccesskeyutil"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="miraccesskeyutil:get-reference-type" as="xs:string">
    <xsl:param name="reference" as="xs:string" />

    <xsl:sequence select="replace($reference, '^[^_]+_([^_]+)_.*$', '$1')" />
  </xsl:function>

  <xsl:param name="access-key-object-types" select="
    tokenize(mcrproperty:one('MCR.ACL.AccessKey.Strategy.AllowedObjectTypes'), ',')
      ! normalize-space(.)[. != '']
  " />

  <xsl:param name="access-key-session-permissions" select="
    tokenize(mcrproperty:one('MCR.ACL.AccessKey.Strategy.AllowedSessionPermissionTypes'), ',')
      ! normalize-space(.)[. != '']
  " />

  <xsl:function name="miraccesskeyutil:is-access-key-allowed" as="xs:boolean">
    <xsl:param name="reference" as="xs:string" />

    <xsl:variable name="type" select="miraccesskeyutil:get-reference-type($reference)" />
    <xsl:sequence select="$type = $access-key-object-types" />
  </xsl:function>

  <xsl:function name="miraccesskeyutil:is-session-access-key-allowed" as="xs:boolean">
    <xsl:sequence select="exists($access-key-session-permissions)" />
  </xsl:function>

  <xsl:function name="miraccesskeyutil:is-session-access-key-permission-allowed" as="xs:boolean">
    <xsl:param name="permission" as="xs:string" />

    <xsl:sequence select="$permission = $access-key-session-permissions" />
  </xsl:function>

  <xsl:function name="miraccesskeyutil:get-object-id-from-url" as="xs:string">
    <xsl:param name="url" as="xs:string" />

    <xsl:sequence select="
      if (contains($url, '/receive/'))
      then replace(substring-after($url, '/receive/'), '[;?].*$', '')
      else ''
    " />
  </xsl:function>

  <xsl:function name="miraccesskeyutil:can-current-user-redeem-access-key" as="xs:boolean">
    <xsl:param name="reference" as="xs:string" />

    <xsl:sequence select="
      if (not(miraccesskeyutil:is-access-key-allowed($reference))) then false()
      else if (not(mcracl:is-current-user-guest-user())) then true()
      else miraccesskeyutil:is-session-access-key-allowed()
    " />
  </xsl:function>

  <xsl:function name="miraccesskeyutil:get-manageable-permissions" as="xs:string*">
    <xsl:param name="reference" as="xs:string" />
    <xsl:param name="permissions" as="xs:string*" />

    <xsl:sequence select="
      $permissions[mcracl:check-permission($reference, concat('manage-access-key-', .))]
    " />
  </xsl:function>

</xsl:stylesheet>
