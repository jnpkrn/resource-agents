<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:int="__internal__"
    xmlns:rha="http://redhat.com/~pkennedy/annotation_namespace/cluster_conf_annot_namespace"
    exclude-result-prefixes="int">
    <xsl:output method="text" indent="no"/>

<xsl:param name="global-init-indent" select="'  '"/>
<xsl:param name="global-indent" select="'  '"/>


<!--
  helper definitions
  -->

<int:agent-parameter-specialization>
    <!-- int:agent @name="..." > int:parameter @name="..." > PATTERN -->
    <!-- WILDCARD (any agent containing such parameter) -->
    <int:agent name="*">
        <int:parameter name="nfslock">
            <choice>
                <!-- note: a bit stricter than what the code enforces -->
                <value type="string">0</value>
                <value type="string">1</value>
                <value type="string">no</value>
                <value type="string">yes</value>
            </choice>
        </int:parameter>
        <int:parameter name="shutdown_wait">
            <data type="int">
                <param name="minInclusive">0</param>
            </data>
        </int:parameter>
    </int:agent>
    <!-- APACHE (should be named, e.g., httpd, not as per foundation) -->
    <int:agent name="apache">
        <!-- int:parameter name="name"/ -->
        <int:parameter name="server_root">
            <data type="string">
                <!-- only enforce starting with slash and at the very least
                     one non-zero length component (otherwise not sane);
                     maximum path length is as per PATH_MAX - 1 (4095)
                     from /usr/include/linux/limits.h; spaces allowed -->
                <param name="pattern">/[\p{IsBasicLatin}\p{IsLatin-1Supplement}]+</param>
                <param name="maxLength">4095</param>
            </data>
        </int:parameter>
        <int:parameter name="config_file">
            <data type="string">
                <!-- only enforce, at the very least, one non-zero length
                     component (otherwise not sane);
                     maximum path length is as per PATH_MAX - 1 (4095)
                     from /usr/include/linux/limits.h; spaces allowed -->
                <param name="pattern">[\p{IsBasicLatin}\p{IsLatin-1Supplement}]+</param>
                <param name="maxLength">4095</param>
            </data>
        </int:parameter>
        <int:parameter name="httpd_options">
            <data type="token">
                <!-- let's limit it at least by $(getconf ARG_MAX) - 1 bytes -->
                <param name="pattern">[\p{IsBasicLatin}\p{IsLatin-1Supplement}]+</param>
                <param name="maxLength">2621440</param>
            </data>
        </int:parameter>
        <!-- shutdown_wait: see WILDCARD -->
        <!-- int:parameter name="service_name"/ -->
    </int:agent>
    <!-- FS -->
    <int:agent name="fs">
        <!-- int:parameter name="name"/ -->
        <int:parameter name="mountpoint">
            <data type="string">
                <!-- only enforce starting with slash and at the very least
                     one non-zero length component (otherwise not sane);
                     maximum path length is as per PATH_MAX - 1 (4095)
                     from /usr/include/linux/limits.h -->
                <param name="pattern">/[\p{IsBasicLatin}\p{IsLatin-1Supplement}-[\s]]+</param>
                <param name="maxLength">4095</param>
            </data>
        </int:parameter>
        <int:parameter name="device">
            <data type="string">
                <!-- like mountpoint + can be specified by UUID=XYZ
                     or LABEL=XYZ -->
                <param name="pattern">/[\p{IsBasicLatin}\p{IsLatin-1Supplement}-[\s]]+|(UUID|LABEL)=[\p{IsBasicLatin}\p{IsLatin-1Supplement}]+</param>
                <param name="maxLength">4095</param>
            </data>
        </int:parameter>
        <int:parameter name="fstype">
            <data type="token">
                <!-- fs.sh only checks for cifs, nfs and nfs4;
                     length of 31 is a reasonable overapproximation -->
                <param name="pattern">[\p{IsBasicLatin}\p{IsLatin-1Supplement}-[\s]]+</param>
                <param name="maxLength">31</param>
            </data>
        </int:parameter>
        <int:parameter name="force_unmount">
            <choice>
                <!-- note: a bit stricter than what the code enforces -->
                <value type="token">0</value>
                <value type="token">1</value>
                <value type="token">no</value>
                <value type="token">yes</value>
                <value type="token">false</value>
                <value type="token">true</value>
            </choice>
        </int:parameter>
        <int:parameter name="quick_status">
            <choice>
                <!-- note: a bit stricter than what the code enforces -->
                <value type="string">0</value>
                <value type="string">1</value>
            </choice>
        </int:parameter>
        <int:parameter name="self_fence">
            <choice>
                <!-- note: a bit stricter than what the code enforces -->
                <value type="token">0</value>
                <value type="token">1</value>
                <value type="token">no</value>
                <value type="token">yes</value>
                <value type="token">false</value>
                <value type="token">true</value>
                <value type="token">off</value>
                <value type="token">on</value>
            </choice>
        </int:parameter>
        <!-- nfslock: see WILDCARD -->
        <int:parameter name="nfsrestart">
            <choice>
                <!-- note: a bit stricter than what the code enforces -->
                <value type="string">0</value>
                <value type="string">1</value>
                <value type="string">no</value>
                <value type="string">yes</value>
            </choice>
        </int:parameter>
        <int:parameter name="fsid">
            <data type="string">
                <!-- prevent from whitespace breaking fragile handling -->
                <param name="pattern">\S+</param>
            </data>
        </int:parameter>
        <int:parameter name="force_fsck">
            <choice>
                <!-- note: a bit stricter than what the code enforces -->
                <value type="string">0</value>
                <value type="string">1</value>
                <value type="string">no</value>
                <value type="string">yes</value>
            </choice>
        </int:parameter>
        <int:parameter name="options">
            <data type="string">
                <!-- prevent from whitespace breaking fragile handling -->
                <param name="pattern">\S*</param>
            </data>
        </int:parameter>
        <int:parameter name="use_findmnt">
            <choice>
                <!-- note: a bit stricter than what the code enforces -->
                <value type="token">0</value>
                <value type="token">1</value>
                <value type="token">no</value>
                <value type="token">yes</value>
                <value type="token">false</value>
                <value type="token">true</value>
                <value type="token">off</value>
                <value type="token">on</value>
            </choice>
        </int:parameter>
    </int:agent>
    <!-- IP -->
    <int:agent name="ip">
        <int:parameter name="address">
            <data type="token">
                <!-- only approximate regexp -->
                <param name="pattern">[0-9A-Fa-f.:]+([/][0-9]+)?</param>
            </data>
        </int:parameter>
        <int:parameter name="family">
            <choice>
                <!-- note: "auto" is more like original expectation, but
                     enforce it to prevent arbitrary non-senses in this
                     context like uppercased INET6 -->
                <value type="token">auto</value>
                <value type="token">inet</value>
                <value type="token">inet6</value>
            </choice>
        </int:parameter>
        <int:parameter name="monitor_link">
            <choice>
                <!-- note: a bit stricter than what the code enforces -->
                <value type="string">0</value>
                <value type="string">1</value>
                <value type="string">no</value>
                <value type="string">yes</value>
                <value type="string">off</value>
                <value type="string">on</value>
            </choice>
        </int:parameter>
        <!-- nfslock: see WILDCARD -->
        <int:parameter name="sleeptime">
            <data type="int">
                <param name="minInclusive">0</param>
            </data>
        </int:parameter>
        <int:parameter name="disable_rdisc">
            <choice>
                <!-- note: a bit stricter than what the code enforces -->
                <value type="string">0</value>
                <value type="string">1</value>
                <value type="string">no</value>
                <value type="string">yes</value>
            </choice>
        </int:parameter>
        <int:parameter name="prefer_interface">
            <data type="string">
                <!-- note: can be up to max(IFNAMSIZ,IFALIASZ) - 1 characters
                     where from include/linux/if.h IFNAMSIZ = 16, IFALIASZ = 256
                     and the terminating null character is subtracted:
                     http://www.gnu.org/software/libc/manual/html_node/Interface-Naming.html
                     resulting in 255 characters (at least one has to be given,
                     at least it would be a bit insane to have an interface
                     called "") -->
                <param name="minLength">1</param>
                <param name="maxLength">255</param>
                <param name="pattern">[\p{IsBasicLatin}\p{IsLatin-1Supplement}-[\s]]+</param>
            </data>
        </int:parameter>
    </int:agent>
    <!-- SCRIPT -->
    <int:agent name="script">
        <int:parameter name="file">
            <data type="token">
                <except>
                    <data type="token">
                        <!-- disallow cluster to control its own core services through a "script" RA -->
                        <param name="pattern">/etc/(rc\.d/)?init\.d/(cman|rgmanager)(\s.*|)</param>
                    </data>
                </except>
            </data>
        </int:parameter>
    </int:agent>
    <!-- MYSQL -->
    <int:agent name="mysql">
        <!-- int:parameter name="name"/ -->
        <int:parameter name="config_file">
            <data type="string">
                <!-- only enforce starting with slash and at the very least
                     one non-zero length component (otherwise not sane);
                     maximum path length is as per PATH_MAX - 1 (4095)
                     from /usr/include/linux/limits.h; spaces allowed -->
                <param name="pattern">/[\p{IsBasicLatin}\p{IsLatin-1Supplement}]+</param>
                <param name="maxLength">4095</param>
            </data>
        </int:parameter>
        <int:parameter name="listen_address">
            <data type="string">
                <!-- can be either IP (v4 only?) address or a hostname;
                     as per netware/mysqld_safe.c limited by PATH_MAX -->
                <param name="pattern">[\p{IsBasicLatin}\p{IsLatin-1Supplement}-[\s]]+</param>
                <param name="maxLength">4095</param>
            </data>
        </int:parameter>
        <int:parameter name="mysqld_options">
            <data type="token">
                <!-- let's limit it at least by $(getconf ARG_MAX) - 1 bytes -->
                <param name="pattern">[\p{IsBasicLatin}\p{IsLatin-1Supplement}]+</param>
                <param name="maxLength">2621440</param>
            </data>
        </int:parameter>
        <int:parameter name="startup_wait">
            <data type="int">
                <param name="minInclusive">0</param>
            </data>
        </int:parameter>
        <!-- shutdown_wait: see WILDCARD -->
        <!-- int:parameter name="service_name"/ -->
    </int:agent>
</int:agent-parameter-specialization>

<xsl:variable name="SP" select="' '"/>
<xsl:variable name="NL" select="'&#xA;'"/>
<xsl:variable name="NLNL" select="'&#xA;&#xA;'"/>
<xsl:variable name="Q" select="'&quot;'"/>
<xsl:variable name="TS" select="'&lt;'"/>
<xsl:variable name="TSc" select="'&lt;/'"/>
<xsl:variable name="TE" select="'&gt;'"/>
<xsl:variable name="TEc" select="'/&gt;'"/>

<xsl:template name="comment">
    <xsl:param name="text" select="''"/>
    <xsl:param name="indent" select="$global-indent"/>
    <xsl:param name="indented" select="''"/>
    <xsl:if test="$indent != 'NONE'">
        <xsl:value-of select="concat($indented, $indent)"/>
    </xsl:if>
    <xsl:value-of select="concat($TS, '!-- ', normalize-space($text), ' --',$TE)"/>
</xsl:template>

<xsl:template name="text">
    <xsl:param name="text" select="''"/>
    <xsl:param name="indent" select="$global-indent"/>
    <xsl:param name="indented" select="''"/>
    <xsl:if test="$indent != 'NONE'">
        <xsl:value-of select="concat($indented, $indent)"/>
    </xsl:if>
    <xsl:value-of select="normalize-space($text)"/>
</xsl:template>

<xsl:template name="tag-start">
    <xsl:param name="name"/>
    <xsl:param name="attrs" select="''"/>
    <xsl:param name="indent" select="$global-indent"/>
    <xsl:param name="indented" select="''"/>
    <xsl:if test="$indent != 'NONE'">
        <xsl:value-of select="concat($indented, $indent)"/>
    </xsl:if>
    <xsl:value-of select="concat($TS, $name)"/>
    <xsl:if test="$attrs != ''">
        <xsl:value-of select="concat($SP, normalize-space($attrs))"/>
    </xsl:if>
    <xsl:value-of select="$TE"/>
</xsl:template>

<xsl:template name="tag-end">
    <xsl:param name="name"/>
    <xsl:param name="indent" select="$global-indent"/>
    <xsl:param name="indented" select="''"/>
    <xsl:if test="$indent != 'NONE'">
        <xsl:value-of select="concat($indented, $indent)"/>
    </xsl:if>
    <xsl:value-of select="concat($TSc, $name)"/>
    <xsl:value-of select="$TE"/>
</xsl:template>

<xsl:template name="pretty-print">
    <xsl:param name="indent" select="$global-indent"/>
    <xsl:param name="indented" select="''"/>
    <xsl:param name="fill-with"/>
    <!--xsl:value-of select="$NL"/-->
    <xsl:for-each select="$fill-with">
        <xsl:choose>
            <xsl:when test="self::comment()">
                <xsl:value-of select="$NL"/>
                <xsl:call-template name="comment">
                    <xsl:with-param name="text" select="."/>
                    <xsl:with-param name="indent" select="$indent"/>
                    <xsl:with-param name="indented" select="concat($indented, $indent)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="self::*">
                <xsl:if test="count(preceding-sibling::*) = 0
                              or
                                  (preceding-sibling::node()[comment() or *])[last()]
                                  !=
                                  preceding-sibling::*[last()]">
                    <xsl:value-of select="$NL"/>
                </xsl:if>
                <xsl:call-template name="tag">
                    <xsl:with-param name="name" select="name()"/>
                    <xsl:with-param name="attrs">
                        <xsl:for-each select="@*">
                            <xsl:value-of select="concat(name(), '=', $Q, ., $Q, $SP)"/>
                        </xsl:for-each>
                    </xsl:with-param>
                    <xsl:with-param name="indent" select="$indent"/>
                    <xsl:with-param name="indented" select="concat($indented, $indent)"/>
                    <xsl:with-param name="fill-with"
                                    select="node()"/>
                </xsl:call-template>
                <xsl:value-of select="$NL"/>
            </xsl:when>
            <xsl:when test="self::text()">
                <xsl:call-template name="text">
                    <xsl:with-param name="text" select="."/>
                    <xsl:with-param name="indent" select="'NONE'"/>
                    <xsl:with-param name="indented" select="$indented"/>
                </xsl:call-template>
                <!-- xsl:value-of select="$NL"/ -->
            </xsl:when>
            <xsl:value-of select="name()"/>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

<xsl:template name="tag">
    <xsl:param name="name"/>
    <xsl:param name="attrs" select="''"/>
    <xsl:param name="indent" select="$global-indent"/>
    <xsl:param name="indented" select="''"/>
    <xsl:param name="fill-with" select="false()"/>
    <xsl:choose>
        <!-- XXX: better test for "empty" fill-with -->
        <xsl:when test="$fill-with != false()">
            <xsl:call-template name="tag-start">
                <xsl:with-param name="name" select="$name"/>
                <xsl:with-param name="attrs" select="$attrs"/>
                <xsl:with-param name="indent" select="$indent"/>
                <xsl:with-param name="indented" select="$indented"/>
            </xsl:call-template>
            <xsl:call-template name="pretty-print">
                <xsl:with-param name="indent" select="$indent"/>
                <xsl:with-param name="indented" select="$indented"/>
                <xsl:with-param name="fill-with" select="$fill-with"/>
            </xsl:call-template>
            <xsl:call-template name="tag-end">
                <xsl:with-param name="name" select="$name"/>
                <xsl:with-param name="indent">
                    <xsl:choose>
                        <xsl:when test="count($fill-with) = 1
                                        and $fill-with[1][self::text()]">
                            <xsl:value-of select="'NONE'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$indent"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="indented" select="$indented"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:if test="$indent != 'NONE'">
                <xsl:value-of select="concat($indented, $indent)"/>
            </xsl:if>
            <xsl:value-of select="concat($TS, $name)"/>
            <xsl:if test="$attrs != ''">
                <xsl:value-of select="concat($SP, normalize-space($attrs))"/>
            </xsl:if>
            <xsl:value-of select="$TEc"/>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="capitalize">
    <xsl:param name="value"/>
    <xsl:value-of select="translate($value,
                                    '_abcdefghijklmnopqrstuvwrxyz',
                                    '-ABCDEFGHIJKLMNOPQRSTUVWRXYZ')"/>
</xsl:template>


<!--
  proceed
  -->

<xsl:template match="/resource-agent">
    <xsl:value-of select="$NL"/>

    <!-- define name=... (start) -->
    <xsl:variable name="capitalized">
        <xsl:call-template name="capitalize">
            <xsl:with-param name="value" select="@name"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="tag-start">
        <xsl:with-param name="name" select="'define'"/>
        <xsl:with-param name="attrs" select="concat(
            'name=', $Q, $capitalized, $Q)"/>
    </xsl:call-template>
    <xsl:value-of select="$NL"/>

        <!-- element name=... rha:description=... (start) -->
        <xsl:call-template name="tag-start">
            <xsl:with-param name="name" select="'element'"/>
            <xsl:with-param name="attrs" select="concat(
                'name=',            $Q, @name,                      $Q, $SP,
                'rha:description=', $Q, normalize-space(shortdesc), $Q)"/>
            <xsl:with-param name="indented"
                            select="$global-init-indent"/>
        </xsl:call-template>
        <xsl:value-of select="$NL"/>

            <!-- choice (start) -->
            <xsl:call-template name="tag-start">
                <xsl:with-param name="name" select="'choice'"/>
                <xsl:with-param name="indented"
                                select="concat($global-init-indent,
                                               $global-indent)"/>
            </xsl:call-template>
            <xsl:value-of select="$NL"/>

                <!-- group (start) -->
                <xsl:call-template name="tag-start">
                    <xsl:with-param name="name" select="'group'"/>
                    <xsl:with-param name="indented"
                                    select="concat($global-init-indent,
                                                   $global-indent,
                                                   $global-indent)"/>
                </xsl:call-template>
                <xsl:value-of select="$NL"/>

                    <!-- (comment) -->
                    <xsl:call-template name="comment">
                        <xsl:with-param name="text">
                            <xsl:text>rgmanager specific stuff</xsl:text>
                        </xsl:with-param>
                        <xsl:with-param name="indented"
                                        select="concat($global-init-indent,
                                                       $global-indent,
                                                       $global-indent,
                                                       $global-indent)"/>
                    </xsl:call-template>
                    <xsl:value-of select="$NL"/>

                    <!-- attribute name="ref" -->
                    <xsl:call-template name="tag">
                        <xsl:with-param name="name" select="'attribute'"/>
                        <xsl:with-param name="attrs" select="concat(
                            'name=',            $Q, 'ref',                    $Q, $SP,
                            'rha:description=', $Q, 'Reference to existing ',
                                                    @name, ' resource in ',
                                                    'the resources section.', $Q)"/>
                        <xsl:with-param name="indented"
                                        select="concat($global-init-indent,
                                                       $global-indent,
                                                       $global-indent,
                                                       $global-indent)"/>
                    </xsl:call-template>
                    <xsl:value-of select="$NL"/>

                <!-- group (end) -->
                <xsl:call-template name="tag-end">
                    <xsl:with-param name="name" select="'group'"/>
                    <xsl:with-param name="indented"
                                    select="concat($global-init-indent,
                                                   $global-indent,
                                                   $global-indent)"/>
                </xsl:call-template>
                <xsl:value-of select="$NL"/>

                <!-- group (start) -->
                <xsl:call-template name="tag-start">
                    <xsl:with-param name="name" select="'group'"/>
                    <xsl:with-param name="indented"
                                    select="concat($global-init-indent,
                                                   $global-indent,
                                                   $global-indent)"/>
                </xsl:call-template>
                <xsl:value-of select="$NL"/>

                <xsl:for-each select="parameters/parameter">
                    <xsl:variable name="use-indented"
                                  select="concat($global-init-indent,
                                                 $global-indent,
                                                 $global-indent,
                                                 $global-indent,
                                                 substring($global-indent, 1,
                                                           number(not(@required = '1'
                                                                      or @primary = '1')) * 64))"/>
                    <xsl:if test="$use-indented != concat($global-init-indent,
                                                          $global-indent,
                                                          $global-indent,
                                                          $global-indent)">

                        <!-- optional (start) -->
                        <xsl:call-template name="tag-start">
                            <xsl:with-param name="name" select="'optional'"/>
                            <xsl:with-param name="indented"
                                            select="concat($global-init-indent,
                                                           $global-indent,
                                                           $global-indent,
                                                           $global-indent)"/>
                        </xsl:call-template>
                        <xsl:value-of select="$NL"/>

                    </xsl:if>

                    <!-- attribute name=... rha:description=... -->
                    <xsl:call-template name="tag">
                        <xsl:with-param name="name" select="'attribute'"/>
                        <xsl:with-param name="attrs" select="concat(
                            'name=',            $Q, @name,                      $Q, $SP,
                            'rha:description=', $Q, normalize-space(shortdesc), $Q)"/>
                        <xsl:with-param name="indented" select="$use-indented"/>
                        <xsl:with-param name="fill-with"
                                        select="(
                                                document('')/*/int:agent-parameter-specialization
                                                    /int:agent[
                                                        @name = '*'
                                                    ]/int:parameter[
                                                        @name = current()/@name
                                                    ]
                                                |
                                                document('')/*/int:agent-parameter-specialization
                                                    /int:agent[
                                                        @name = current()/../../@name
                                                    ]/int:parameter[
                                                        @name = current()/@name
                                                    ]
                                                )[last()]/*"/>
                    </xsl:call-template>
                    <xsl:value-of select="$NL"/>

                    <xsl:if test="$use-indented != concat($global-init-indent,
                                                          $global-indent,
                                                          $global-indent,
                                                          $global-indent)">

                            <!-- optional (end) -->
                            <xsl:call-template name="tag-end">
                                <xsl:with-param name="name" select="'optional'"/>
                                <xsl:with-param name="indented"
                                                select="concat($global-init-indent,
                                                               $global-indent,
                                                               $global-indent,
                                                               $global-indent)"/>
                            </xsl:call-template>
                            <xsl:value-of select="$NL"/>

                    </xsl:if>
                </xsl:for-each>

                <!-- group (end) -->
                <xsl:call-template name="tag-end">
                    <xsl:with-param name="name" select="'group'"/>
                    <xsl:with-param name="indented"
                                    select="concat($global-init-indent,
                                                   $global-indent,
                                                   $global-indent)"/>
                </xsl:call-template>
                <xsl:value-of select="$NL"/>

            <!-- choice (end) -->
            <xsl:call-template name="tag-end">
                <xsl:with-param name="name" select="'choice'"/>
                <xsl:with-param name="indented"
                                select="concat($global-init-indent,
                                               $global-indent)"/>
            </xsl:call-template>
            <xsl:value-of select="$NL"/>

            <xsl:call-template name="tag">
                <xsl:with-param name="name" select="'ref'"/>
                <xsl:with-param name="attrs" select="concat(
                    'name=', $Q, 'RESOURCECOMMONPARAMS', $Q)"/>
                <xsl:with-param name="indented"
                                select="concat($global-init-indent,
                                               $global-indent)"/>
            </xsl:call-template>
            <xsl:value-of select="$NL"/>

            <!-- optional (start) -->
            <xsl:call-template name="tag-start">
                <xsl:with-param name="name" select="'optional'"/>
                <xsl:with-param name="indented"
                                select="concat($global-init-indent,
                                               $global-indent)"/>
            </xsl:call-template>
            <xsl:value-of select="$NL"/>

                <!-- ref name="CHILDREN" -->
                <xsl:call-template name="tag">
                    <xsl:with-param name="name" select="'ref'"/>
                    <xsl:with-param name="attrs" select="concat(
                        'name=', $Q, 'CHILDREN', $Q)"/>
                    <xsl:with-param name="indented"
                                    select="concat($global-init-indent,
                                                   $global-indent,
                                                   $global-indent)"/>
                </xsl:call-template>
                <xsl:value-of select="$NL"/>

            <!-- optional (end) -->
            <xsl:call-template name="tag-end">
                <xsl:with-param name="name" select="'optional'"/>
                <xsl:with-param name="indented"
                                select="concat($global-init-indent,
                                               $global-indent)"/>
            </xsl:call-template>
            <xsl:value-of select="$NL"/>

        <!-- element (end) -->
        <xsl:call-template name="tag-end">
            <xsl:with-param name="name" select="'element'"/>
            <xsl:with-param name="indented"
                            select="$global-init-indent"/>
        </xsl:call-template>
        <xsl:value-of select="$NL"/>

    <!-- define (end) -->
    <xsl:call-template name="tag-end">
        <xsl:with-param name="name" select="'define'"/>
    </xsl:call-template>
    <xsl:value-of select="$NLNL"/>

</xsl:template>

</xsl:stylesheet>
