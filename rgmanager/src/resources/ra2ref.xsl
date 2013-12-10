<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" indent="yes"/>
<xsl:message>NOTE: if you see this, there is some chance you are using outdated cman package</xsl:message>
<xsl:template name="capitalize">
	<xsl:param name="value"/>
	<xsl:variable name="normalized" select="translate($value, '_abcdefghijklmnopqrstuvwrxyz', '-ABCDEFGHIJKLMNOPQRSTUVWRXYZ')"/>
	<xsl:value-of select="$normalized"/>
</xsl:template>
<xsl:template match="/resource-agent[1]">
        &lt;!-- NOTE: if you see this, there is some chance you are using outdated cman package --&gt;
        &lt;ref name="<xsl:call-template name="capitalize"><xsl:with-param name="value" select="@name"/></xsl:call-template>"/&gt;</xsl:template>
<xsl:template match="/resource-agent">
        &lt;ref name="<xsl:call-template name="capitalize"><xsl:with-param name="value" select="@name"/></xsl:call-template>"/&gt;</xsl:template>
</xsl:stylesheet>
